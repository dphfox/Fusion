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
-- Graph
local depend = require(Package.Graph.depend)
-- State
local peek = require(Package.State.peek)
local castToState = require(Package.State.castToState)
-- Utility
local never = require(Package.Utility.never)

local Constellation = require(Package.State.For.Constellation)

type Self<S, KI, KO, VI, VO> = Types.For<KO, VO> & {
	_constellation: Constellation.Self<S, KI, KO, VI, VO>
}

local class = {}
class.type = "State"
class.kind = "For"
class.timeliness = "lazy"

local METATABLE = {__index = class}

local function For<S, KI, KO, VI, VO>(
	scope: Types.Scope<S>,
	inputTable: Types.UsedAs<{[KI]: VI}>,
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
			_constellation = Constellation(
				scope,
				inputTable,
				processor
			)
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
	if self.scope == nil then
		return false
	end
	local outerScope = self.scope :: S & Types.Scope<unknown>

	depend(self, self._constellation)
	table.clear(self._EXTREMELY_DANGEROUS_usedAsValue)
	self._constellation:populate(
		function<T>(
			maybeState: Types.UsedAs<T>
		): T
			local state = castToState(maybeState)
			if state ~= nil then
				depend(self, state)
			end
			return peek(maybeState)
		end,
		self._EXTREMELY_DANGEROUS_usedAsValue
	)

	return true
end

return For