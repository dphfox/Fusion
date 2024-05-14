--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	State object for measuring time since an event using a reference timer.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
-- Graph
local depend = require(Package.Graph.depend)
local change = require(Package.Graph.change)
-- State
local peek = require(Package.State.peek)

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

local METATABLE = {}
METATABLE.__index = class

local function Stopwatch(
	scope: Types.Scope<unknown>,
	timer: Types.StateObject<number>
): Self
	local self: Self = setmetatable(
		{
			awake = true,
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
	table.insert(scope, self)
	depend(self, timer) -- TODO: lifetime analysis
	return self
end

function class.destroy(
	self: Self
): ()
	if self.scope == nil then
		External.logError("destroyedTwice", nil, "Stopwatch")
	end
	self.scope = nil
end

function class.zero(
	self: Self
): ()
	self._measureTimeSince = peek(self._timer)
	self._EXTREMELY_DANGEROUS_usedAsValue = 0
	if self:_evaluate() then
		change(self)
	end
end

function class.pause(
	self: Self
): ()
	self._playing = false
	-- Don't need to evaluate here because pausing a stopwatch shouldn't change
	-- its value
end

function class.unpause(
	self: Self
): ()
	self._playing = true
	self._measureTimeSince = peek(self._timer) - self._EXTREMELY_DANGEROUS_usedAsValue
	depend(self, self._timer)
	-- Don't need to evaluate here because unpausing a stopwatch shouldn't 
	-- change its value
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

return Stopwatch