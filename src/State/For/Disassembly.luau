--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Breaks down an input table into reactive sub-objects for each pair.
]]

local Package = script.Parent.Parent.Parent
local Types = require(Package.Types)
-- Logging
local logError = require(Package.Logging.logError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local parseError = require(Package.Logging.parseError)
-- Graph
local depend = require(Package.Graph.depend)
-- State
local peek = require(Package.State.peek)
local castToState = require(Package.State.castToState)
local Value = require(Package.State.Value)
-- Memory
local doCleanup = require(Package.Memory.doCleanup)
local deriveScope = require(Package.Memory.deriveScope)
local scopePool = require(Package.Memory.scopePool)
-- Utility
local nameOf = require(Package.Utility.nameOf)

export type Self<S, KI, KO, VI, VO> = Types.GraphObject & {
	populate: (Self<S, KI, KO, VI, VO>, Types.Use, output: {[KO]: VO}) -> (),
	scope: (S & Types.Scope<unknown>)?,
	_inputTable: Types.UsedAs<{[KI]: VI}>,
	_processor: (
		Types.Scope<S>,
		Types.StateObject<{key: KI, value: VI}>
	) -> (Types.StateObject<{key: KO?, value: VO?}>),
	_reassembly: Types.GraphObject,
	_subObjects: {[ForSubObject<S, KI, KO, VI, VO>]: true},
}
type ForSubObject<S, KI, KO, VI, VO> = {
	-- Not all sub objects need to store a scope, for example if the scope
	-- remains empty, it'll be given back to the scope pool.
	maybeScope: Types.Scope<S>?,
	lastInputKey: KI,
	lastInputValue: VI,
	setInputKey: (KI) -> (),
	setInputValue: (VI) -> ()
}

local class = {}
class.type = "Graph"
class.kind = "For.Disassembly"
class.timeliness = "lazy"

local METATABLE = {__index = class}

local function Disassembly<S, KI, KO, VI, VO>(
	scope: S & Types.Scope<unknown>,
	inputTable: Types.UsedAs<{[KI]: VI}>,
	processor: (
		Types.Scope<S>,
		Types.StateObject<{key: KI, value: VI}>
	) -> (Types.StateObject<{key: KO?, value: VO?}>)
): Self<S, KI, KO, VI, VO>
	local self = setmetatable(
		{
			dependencySet = {},
			dependentSet = {},
			scope = scope,
			validity = "invalid",
			_inputTable = inputTable,
			_processor = processor,
			_subObjects = {}
		}, 
		METATABLE
	) :: any

	local inputState = castToState(inputTable)
	if inputState ~= nil then
		self.dependencySet[inputState] = true
		inputState.dependentSet[self] = true
	end

	table.insert(scope, self)
	return self
end

function class.destroy<S, KI, KO, VI, VO>(
	self: Self<S, KI, KO, VI, VO>
)
	if self.scope == nil then
		logError("destroyedTwice", nil, "For.Disassembly")
	end
	self.scope = nil
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
end

function class._evaluate<S, KI, KO, VI, VO>(
	self: Self<S, KI, KO, VI, VO>
): boolean
	local outerScope = self.scope :: S & Types.Scope<unknown>

	local inputState = castToState(self._inputTable)
	if inputState ~= nil then
		if inputState.scope == nil then
			logError(
				"useAfterDestroy",
				nil,
				`The input {nameOf(inputState, "table")}`,
				`the For object that is watching it`
			)
		end
		depend(self, inputState)
	end

	local pendingPairs = {} :: {[KI]: VI}
	for key, value in peek(self._inputTable) do
		pendingPairs[key] = value
	end

	local newSubObjects = {} :: typeof(self._subObjects)

	-- TODO: reuse sub objs with nil output keys, so long as they match values.
	-- This ensures they don't get recomputed either.
	for subObject in self._subObjects do
		local reused = false
		local oldInputKey = subObject.lastInputKey
		local oldInputValue = subObject.lastInputValue
		local newInputKey: KI
		-- Reuse when the keys are the same. (If the values are also the same, 
		-- then nothing is done - nice 🙂)
		if pendingPairs[oldInputKey] ~= nil then
			reused = true
			newInputKey = oldInputKey
		else -- Try and reuse some other pair instead.
			for pendingKey, pendingValue in pendingPairs do
				reused = true
				newInputKey = pendingKey
				if pendingValue == oldInputValue then
					-- If the values are the same, then no need to update those,
					-- so prefer this choice to any other.
					break 
				end
			end
		end
		if reused then
			local newInputValue = pendingPairs[oldInputKey]
			newSubObjects[subObject] = true
			if newInputKey ~= oldInputKey then
				subObject.lastInputKey = newInputKey
				subObject.setInputKey(newInputKey)
			end
			if newInputValue ~= oldInputValue then
				subObject.lastInputValue = newInputValue
				subObject.setInputValue(newInputValue)
			end
			pendingPairs[newInputKey] = nil
		else -- Too many sub objects for the number of pairs.
			if subObject.maybeScope ~= nil then
				doCleanup(subObject.maybeScope)
				scopePool.clearAndGive(subObject.maybeScope)
				subObject.maybeScope = nil
			end
		end
	end

	-- Generate new objects if needed to cover the remaining pending pairs.
	for pendingKey, pendingValue in pendingPairs do
		local subObjectScope = deriveScope(outerScope)
		-- TODO: processing
		local subObjectScope = scopePool.giveIfEmpty(subObjectScope)
		
		newSubObjects[{
			maybeScope = subObjectScope,
			lastInputKey = pendingKey,
			lastInputValue = pendingValue,
			setInputKey = function(key: KI)

			end,
			setInputValue = function(value: VI)

			end
		}] = true
	end

	self._subObjects = newSubObjects

	return true
end

return Disassembly