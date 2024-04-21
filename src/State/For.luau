--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	The private generic implementation for all public `For` objects.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
-- Logging
local logError = require(Package.Logging.logError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local parseError = require(Package.Logging.parseError)
-- State
local peek = require(Package.State.peek)
local castToState = require(Package.State.castToState)
local Value = require(Package.State.Value)
-- Memory
local doCleanup = require(Package.Memory.doCleanup)
local deriveScope = require(Package.Memory.deriveScope)
local scopePool = require(Package.Memory.scopePool)
-- Utility
local never = require(Package.Utility.never)

type Self<S, KI, KO, VI, VO> = Types.For<KO, VO> & {
	scope: (S & Types.Scope<unknown>)?,
	_inputTable: Types.UsedAs<{[KI]: VI}>,
	_processor: (
		Types.Scope<S>,
		Types.StateObject<{key: KI, value: VI}>
	) -> (Types.StateObject<{key: KO?, value: VO?}>),
	_subObjects: {[ForSubObject<S, KI, VI, KO, VO>]: true},
}
type ForSubObject<S, KI, VI, KO, VO> = {
	inputPair: Types.Value<{key: KI, value: VI}>,
	outputPair: Types.StateObject<{key: KO, value: VO?}>,
	maybeScope: Types.Scope<S>?
}

local class = {}
class.type = "State"
class.kind = "For"
class.timeliness = "lazy"

local METATABLE = {__index = class}

local function For<S, KI, KO, VI, VO>(
	scope: Types.Scope<S>,
	inputTable: Types.UsedAs<{ [KI]: VI }>,
	processor: (
		Types.Scope<S>,
		Types.StateObject<{key: KI, value: VI}>
	) -> (Types.StateObject<{key: KO?, value: VO?}>)
): Self<S, KI, KO, VI, VO>
	local self: Self<S, KI, KO, VI, VO> = setmetatable(
		{
			dependencySet = {},
			dependentSet = {},
			scope = scope,
			validity = "invalid",
			_EXTREMELY_DANGEROUS_usedAsValue = {},
			_inputTable = inputTable,
			_processor = processor,
			_subObjects = {}
		}, 
		METATABLE
	) :: any
	table.insert(scope, self)
	return self
end

function class.destroy<S, KI, KO, VI, VO>(
	self: Self<S, KI, KO, VI, VO>
)
	if self.scope == nil then
		logError("destroyedTwice", nil, "For")
	end
	self.scope = nil
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
	for subObject in self._subObjects do
		if subObject.maybeScope ~= nil then
			doCleanup(subObject.maybeScope)
			scopePool.clearAndGive(subObject.maybeScope)
		end
	end
end

function class.get<S, KI, KO, VI, VO>(
	_self: Self<S, KI, KO, VI, VO>
): never
	logError("stateGetWasRemoved")
	return never()
end

function class._evaluate<S, KI, KO, VI, VO>(
	self: Self<S, KI, KO, VI, VO>
): boolean
	local PRINTSHIT = _G.PRINTSHIT == true
	_G.PRINTSHIT = nil
	if self.scope == nil then
		return false
	end
	local outerScope = self.scope :: S & Types.Scope<unknown>

	-- TODO: should do a lifetime check here?
	local inputState = castToState(self._inputTable)
	if inputState ~= nil then
		inputState.dependentSet[self], self.dependencySet[inputState] = true, true
	end

	local pairsToInclude = {} :: {[KI]: {[VI]: true}}
	for key, value in peek(self._inputTable) do
		if pairsToInclude[key] == nil then
			pairsToInclude[key] = {[value] = true}
		else
			pairsToInclude[key][value] = true
		end
	end

	local oldSubObjects = self._subObjects
	self._subObjects = {}
	local newSubObjects = self._subObjects

	-- First, try and reuse sub objs who match both the key and value of a
	-- remaining pair. This can be done with no recomputation.
	-- NOTE: we also reuse sub objs with nil output keys here, so long as
	-- they match values. This ensures they don't get recomputed either.
	for tryReuseSubObject in oldSubObjects do
		local value = peek(tryReuseSubObject.inputPair).value
		if peek(tryReuseSubObject.outputPair).key == nil then
			for key, remainingValues in pairsToInclude do
				if remainingValues[value] ~= nil then
					remainingValues[value] = nil
					tryReuseSubObject.inputPair:set({key = key, value = value})
					newSubObjects[tryReuseSubObject] = true
					oldSubObjects[tryReuseSubObject] = nil
					break
				end
			end
		else
			local key = peek(tryReuseSubObject.inputPair).key
			local remainingValues = pairsToInclude[key]
			if remainingValues ~= nil and remainingValues[value] ~= nil then
				remainingValues[value] = nil
				newSubObjects[tryReuseSubObject] = true
				oldSubObjects[tryReuseSubObject] = nil
			end
		end
		
	end
	-- Next, try and reuse sub objs who match the key of a remaining pair.
	-- The value will change but the key will stay stable.
	for tryReuseSubObject in oldSubObjects do
		local key = peek(tryReuseSubObject.inputPair).key
		local remainingValues = pairsToInclude[key]
		if remainingValues ~= nil then
			local value = next(remainingValues)
			if value ~= nil then
				remainingValues[value] = nil
				tryReuseSubObject.inputPair:set({key = key, value = value})
				newSubObjects[tryReuseSubObject] = true
				oldSubObjects[tryReuseSubObject] = nil
			end
		end
	end
	-- Next, try and reuse sub objs who match the value of a remaining pair.
	-- The key will change but the value will stay stable.
	for tryReuseSubObject in oldSubObjects do
		local value = peek(tryReuseSubObject.inputPair).value
		for key, remainingValues in pairsToInclude do
			if remainingValues[value] ~= nil then
				remainingValues[value] = nil
				tryReuseSubObject.inputPair:set({key = key, value = value})
				newSubObjects[tryReuseSubObject] = true
				oldSubObjects[tryReuseSubObject] = nil
				break
			end
		end
	end
	-- Finally, try and reuse any remaining sub objs, even if they do not
	-- match a pair. Both key and value will be changed.
	for tryReuseSubObject in oldSubObjects do
		for key, remainingValues in pairsToInclude do
			local value = next(remainingValues)
			if value ~= nil then
				remainingValues[value] = nil
				tryReuseSubObject.inputPair:set({key = key, value = value})
				newSubObjects[tryReuseSubObject] = true
				oldSubObjects[tryReuseSubObject] = nil
				break
			end
		end
	end
	-- By this point, we can be in one of three cases:
	-- 1) some existing sub objs are left over; no remaining pairs (shrunk)
	-- 2) no existing sub objs are left over; no remaining pairs (same size)
	-- 3) no existing sub objs are left over; some remaining pairs (grew)
	-- So, existing sub objs should be destroyed, and remaining pairs should
	-- be created. This accomodates for table growth and shrinking.
	for unusedSubObject in oldSubObjects do
		if unusedSubObject.maybeScope ~= nil then
			doCleanup(unusedSubObject.maybeScope)
			scopePool.clearAndGive(unusedSubObject.maybeScope)
		end
	end
	
	for key, remainingValues in pairsToInclude do
		for value in remainingValues do
			local innerScope = deriveScope(outerScope)
			local inputPair = Value(innerScope, {key = key, value = value})
			local processOK, outputPair = xpcall(self._processor, parseError, innerScope, inputPair)
			local innerScope = scopePool.giveIfEmpty(innerScope)
			if processOK then
				local subObject: ForSubObject<S, KI, VI, KO, VO> = {
					inputPair = inputPair,
					outputPair = outputPair,
					scope = innerScope
				} :: any
				newSubObjects[subObject] = true
			else
				local errorObj = (outputPair :: any) :: Types.Error
				logErrorNonFatal("callbackError", errorObj)
			end
		end
	end

	local output = self._EXTREMELY_DANGEROUS_usedAsValue
	table.clear(output)

	for subObject in newSubObjects do
		local pair = subObject.outputPair
		--pair.dependentSet[self], self.dependencySet[pair] = true, true
		local key, value = peek(pair).key, peek(pair).value
		if value == nil then
			continue
		end
		if key == nil then
			key = (#output + 1) :: any
		end
		if output[key] == nil then
			output[key] = value
		else
			logErrorNonFatal("forKeyCollision", nil, key)
		end
	end

	return true
end

return For