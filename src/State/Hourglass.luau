--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Constructs a new state object with an intervaled callback.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
local External = require(Package.External)
local peek = require(Package.State.peek)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

local RunService = game:GetService("RunService")

local class = {}
class.type = "Hourglass"

local CLASS_METATABLE = {__index = class}

--[[
	Called on intervaled tick.
]]
function class:tick(): boolean
	local self = self :: InternalTypes.Hourglass
	for _, callback in pairs(self._tickListeners) do
		External.doTaskImmediate(callback)
	end; return false
end

--[[
	Updates the current interval along with the next timed tick.
]]
function class:update(): boolean
	local self = self :: InternalTypes.Hourglass
	local interval = peek(self._interval)
	if typeof(interval) ~= "number" then
		External.logErrorNonFatal("mistypedHourglassInterval", nil, typeof(interval))
	elseif interval <= 0 then
		External.logErrorNonFatal("invalidHourglassInterval", nil, interval)
	else
		self._currentInterval = interval
	end
	self._nextTick = os.clock() + peek(self._currentInterval)
	return false
end

--[[
	Adds an on tick listener. When playing, the listener will be fired upon
    intervaled tick.

	Returns a function which, when called, will disconnect the tick listener.
	As long as there is at least one active tick listener, the Hourglass
	will be held in memory, preventing GC, so disconnecting is important.
]]
function class:onTick(
	callback: () -> ()
): () -> ()
	local self = self :: InternalTypes.Hourglass
	local uniqueIdentifier = {}
	self._tickListeners[uniqueIdentifier] = callback
	return function()
		self._tickListeners[uniqueIdentifier] = nil
	end
end

--[[
	Similar to `class:onTick()`, however it runs the provided callback
	immediately.
]]
function class:onBind(
	callback: () -> ()
): () -> ()
	local self = self :: InternalTypes.Hourglass
	External.doTaskImmediate(callback)
	return self:onTick(callback)
end

function class:_peek(): unknown
	local self = self :: InternalTypes.Hourglass
	if self._connection then
		return self._nextTick - os.clock()
	else
		return peek(self._currentInterval)
	end
end

function class:get()
	External.logError("stateGetWasRemoved")
end

--[[
	Starts the intervaled ticks.
]]
function class:start()
	local self = self :: InternalTypes.Hourglass
	if self._connection then return end
	self:update()
	self._connection = RunService.Heartbeat:Connect(function()
		local now = os.clock()
		if now >= self._nextTick then
			self:update()
			self:tick()
		end
	end)
end

--[[
	Stops the intervaled ticks.
]]
function class:stop()
	local self = self :: InternalTypes.Hourglass
	if self._connection == nil then return end
	self._connection:Disconnect()
	self._connection = nil
end

local function Hourglass(
	scope: Types.Scope<unknown>,
	interval: Types.UsedAs<number>?
): Types.Hourglass
    if interval == nil then
        External.logError("scopeMissing", nil, "Hourglass", "myScope:Hourglass(interval)")
    end

	local intervalState = typeof(interval) == "table" and (interval :: any).dependentSet ~= nil

    -- apply defaults for tick interval
	if interval == nil then
		interval = .001
	end
	if typeof(peek(interval)) ~= "number" then
		External.logErrorNonFatal("mistypedHourglassInterval", nil, typeof(interval))
	elseif peek(interval) <= 0 then
		External.logErrorNonFatal("invalidHourglassInterval", nil, peek(interval))
	end

	local self = setmetatable({
		scope = scope,
		dependencySet = if intervalState then {[interval] = true} else {},
		dependentSet = {},
		_tickListeners = {},

		_interval = interval,
		_currentInterval = peek(interval),
		_nextTick = nil,
		_connection = nil
	}, CLASS_METATABLE)
	local self = (self :: any) :: InternalTypes.Hourglass

	local destroy = function()
		self:stop()
		self.scope = nil
		for dependency in pairs(self.dependencySet) do
			dependency.dependentSet[self] = nil
		end
	end
	self.oldestTask = destroy
	table.insert(scope, destroy)

    if intervalState then
		local interval: any = interval
		if interval.scope == nil then
			External.logError(
				"useAfterDestroy",
				nil,
				`The {interval.kind or interval.type or "interval"} object`,
				`the Hourglass`
			)
		elseif whichLivesLonger(scope, self, interval.scope, interval) == "definitely-a" then
			local interval: any = interval
			External.logWarn(
				"possiblyOutlives",
				`The {interval.kind or interval.type or "interval"} object`,
				`the Hourglass`
			)
		end
		-- add this object to the watched object's dependent set
		interval.dependentSet[self] = true
	end

	return self
end

return Hourglass