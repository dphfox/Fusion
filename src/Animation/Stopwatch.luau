--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	State object for measuring time since an event using a reference timer.

	TODO: this should not be exposed to users until it has a proper reactive API
	surface
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
-- Memory
local checkLifetime = require(Package.Memory.checkLifetime)
-- Graph
local depend = require(Package.Graph.depend)
local change = require(Package.Graph.change)
-- State
local peek = require(Package.State.peek)
-- Utility
local nicknames = require(Package.Utility.nicknames)

export type Stopwatch = Types.StateObject<number> & {
	zero: (Stopwatch) -> (),
	pause: (Stopwatch) -> (),
	unpause: (Stopwatch) -> ()
}

type Self = Stopwatch & {
	_measureTimeSince: number,
	_playing: boolean,
	_timer: Types.StateObject<number>
}

local class = {}
class.type = "State"
class.kind = "Stopwatch"
class.timeliness = "lazy"

local METATABLE = table.freeze {__index = class}

local function Stopwatch(
	scope: Types.Scope<unknown>,
	timer: Types.StateObject<number>
): Stopwatch
	local createdAt = os.clock()
	local self: Self = setmetatable(
		{
			awake = true,
			createdAt = createdAt,
			dependencySet = {},
			dependentSet = {},
			lastChange = nil,
			scope = scope,
			validity = "invalid",
			_EXTREMELY_DANGEROUS_usedAsValue = 0,
			_measureTimeSince = 0, -- this should be set on unpause
			_playing = false,
			_timer = timer
		}, 
		METATABLE
	) :: any
	local destroy = function()
		self.scope = nil
	end
	self.oldestTask = destroy
	nicknames[self.oldestTask] = "Stopwatch"
	table.insert(scope, destroy)

	checkLifetime.bOutlivesA(
		scope, self.oldestTask,
		timer.scope, timer.oldestTask,
		checkLifetime.formatters.parameter, "timer"
	)
	depend(self, timer)
	return self
end

function class.zero(
	self: Self
): ()
	local newTimepoint = peek(self._timer)
	if newTimepoint ~= self._measureTimeSince then
		self._measureTimeSince = newTimepoint
		self._EXTREMELY_DANGEROUS_usedAsValue = 0
		change(self)
	end
end

function class.pause(
	self: Self
): ()
	if self._playing == true then
		self._playing = false
		change(self)
	end
end

function class.unpause(
	self: Self
): ()
	if self._playing == false then
		self._playing = true
		self._measureTimeSince = peek(self._timer) - self._EXTREMELY_DANGEROUS_usedAsValue
		change(self)
	end
end

function class._evaluate(
	self: Self
): boolean
	if self._playing then
		depend(self, self._timer)
		local currentTime = peek(self._timer)
		local oldValue = self._EXTREMELY_DANGEROUS_usedAsValue
		local newValue = currentTime - self._measureTimeSince
		self._EXTREMELY_DANGEROUS_usedAsValue = newValue
		return oldValue ~= newValue
	else
		return false
	end
	
end

table.freeze(class)
return Stopwatch