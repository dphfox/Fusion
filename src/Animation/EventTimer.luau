--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	State object that outputs the last time a reactive graph event occured.
	A reference timer is used because timestamps from the reactive graph are not
	guaranteed to correspond to the external time source.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
-- Graph
local depend = require(Package.Graph.depend)
-- State
local peek = require(Package.State.peek)

type Self = Types.StateObject<number> & {
	_measureTimeSince: number?,
	_timer: Types.StateObject<number>,
	_watchingGraph: Types.GraphObject,
	_watchingLastChange: number?
}

local class = {}
class.type = "State"
class.kind = "EventTimer"
class.timeliness = "eager"

local METATABLE = {}
METATABLE.__index = class

local function EventTimer(
	scope: Types.Scope<unknown>,
	watchingGraph: Types.GraphObject,
	timer: Types.StateObject<number>
): Self
	local self: Self = setmetatable(
		{
			dependencySet = {},
			dependentSet = {},
			lastChange = nil,
			scope = scope,
			validity = "invalid",
			_EXTREMELY_DANGEROUS_usedAsValue = nil,
			_measureTimeSince = nil,
			_timer = timer,
			_watchingGraph = watchingGraph,
			_watchingLastChange = nil
		}, 
		METATABLE
	) :: any
	table.insert(scope, self)
	return self
end

function class.destroy(
	self: Self
): ()
	if self.scope == nil then
		External.logError("destroyedTwice", nil, "EventTimer")
	end
	self.scope = nil
end

function class._evaluate(
	self: Self
): boolean
	depend(self, self._watchingGraph)
	depend(self, self._timer)
	local newWatchingLastChange = self._watchingGraph.lastChange
	local currentTime = peek(self._timer)
	local measureTimeSince = self._measureTimeSince or -math.huge
	local watchingDidChange = newWatchingLastChange ~= self._watchingLastChange
	if watchingDidChange then
		self._measureTimeSince = currentTime
	end
	local oldValue = self._EXTREMELY_DANGEROUS_usedAsValue
	local newValue = currentTime - measureTimeSince
	self._EXTREMELY_DANGEROUS_usedAsValue = newValue
	return oldValue ~= newValue
end

return EventTimer