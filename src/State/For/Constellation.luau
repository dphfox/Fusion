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
-- State
local castToState = require(Package.State.castToState)

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
class.type = "For"
class.kind = "For.Constellation"
class.timeliness = "lazy"

local METATABLE = {__index = class}

local function Constellation<S, KI, VI, KO, VO>(
	scope: S & Types.Scope<unknown>,
	inputTable: Types.UsedAs<{[KI]: VI}>,
	processor: (
		Types.Scope<S>,
		Types.StateObject<{key: KI, value: VI}>
	) -> (Types.StateObject<{key: KO?, value: VO?}>)
): Self<S, KI, VI, KO, VO>
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

function class.destroy<S, KI, VI, KO, VO>(
	self: Self<S, KI, VI, KO, VO>
)
	if self.scope == nil then
		logError("destroyedTwice", nil, "For.Constellation")
	end
	self.scope = nil
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
end

function class._evaluate<S, KI, VI, KO, VO>(
	self: Self<S, KI, VI, KO, VO>
): boolean
	return true
end

return Constellation