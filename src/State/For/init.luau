--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	The generic implementation for all `For` objects.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
-- Graph
local depend = require(Package.Graph.depend)
-- State
local peek = require(Package.State.peek)
local castToState = require(Package.State.castToState)
local ForTypes = require(Package.State.For.ForTypes)
-- Utility
local never = require(Package.Utility.never)
local nicknames = require(Package.Utility.nicknames)

local Disassembly = require(Package.State.For.Disassembly)

type Self<S, KI, KO, VI, VO> = Types.For<KO, VO> & {
	_disassembly: ForTypes.Disassembly<S, KI, KO, VI, VO>
}

local class = {}
class.type = "State"
class.kind = "For"
class.timeliness = "lazy"

local METATABLE = table.freeze {__index = class}

local function For<S, KI, KO, VI, VO>(
	scope: Types.Scope<S>,
	inputTable: Types.UsedAs<{[KI]: VI}>,
	constructor: (
		Types.Scope<S>,
		initialKey: KI,
		initialValue: VI
	) -> ForTypes.SubObject<S, KI, KO, VI, VO>
): Types.For<KO, VO>
	local createdAt = os.clock()
	local self: Self<S, KI, KO, VI, VO> = setmetatable(
		{
			createdAt = createdAt,
			dependencySet = {},
			dependentSet = {},
			scope = scope,
			validity = "invalid",
			_EXTREMELY_DANGEROUS_usedAsValue = {},
			_disassembly = Disassembly(
				scope,
				inputTable,
				constructor
			)
		}, 
		METATABLE
	) :: any

	local destroy = function()
		self.scope = nil
		for dependency in pairs(self.dependencySet) do
			dependency.dependentSet[self] = nil
		end
	end
	self.oldestTask = destroy
	nicknames[self.oldestTask] = "For"
	table.insert(scope, destroy)

	return self
end

function class.get<S, KI, KO, VI, VO>(
	_self: Self<S, KI, KO, VI, VO>
): never
	External.logError("stateGetWasRemoved")
	return never()
end

function class._evaluate<S, KI, KO, VI, VO>(
	self: Self<S, KI, KO, VI, VO>
): boolean
	if self.scope == nil then
		return false
	end
	local outerScope = self.scope :: S & Types.Scope<unknown>

	depend(self, self._disassembly)
	table.clear(self._EXTREMELY_DANGEROUS_usedAsValue)
	self._disassembly:populate(
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

table.freeze(class)
return For