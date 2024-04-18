--!strict
--!nolint LocalShadow

--[[
	Constructs a new state object with an intervaled callback.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
local External = require(Package.External)
local isState = require(Package.State.isState)
local peek = require(Package.State.peek)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)
local logWarn = require(Package.Logging.logWarn)
local logError = require(Package.Logging.logError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)

local RunService = game:GetService("RunService")

local class = {}
class.type = "Hourglass"

local CLASS_METATABLE = {__index = class}

--[[
	Called on intervaled tick.
]]
function class:update(): boolean
	local self = self :: InternalTypes.Hourglass
	local interval = peek(self._interval)
	if typeof(interval) ~= "number" then
		logErrorNonFatal("mistypedHourglassInterval", nil, typeof(interval))
	elseif interval <= 0 then
		logErrorNonFatal("invalidHourglassInterval", nil, interval)
	else
		self._currentInterval = interval
	end
	for _, callback in pairs(self._tickListeners) do
		External.doTaskImmediate(callback)
	end
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
	logError("stateGetWasRemoved")
end

--[[
	Starts the intervaled ticks.
]]
function class:start()
	local self = self :: InternalTypes.Hourglass
	-- connection already exists means the hourglass is already running
	if self._connection then return end
	self._nextTick = os.clock() + peek(self._currentInterval)
	self._connection = RunService.Heartbeat:Connect(function()
		local now = os.clock()
		if now >= self._nextTick then
			self._nextTick = now + peek(self._currentInterval)
			self:update()
		end
	end)
	table.insert(self.scope, self._connection)
end

--[[
	Stops the intervaled ticks.
]]
function class:stop()
	local self = self :: InternalTypes.Hourglass
	-- if the connection isn't found then the hourglass is already stopped
	if self._connection == nil then return end
	table.remove(self.scope, table.find(self.scope, self._connection))
	self._connection:Disconnect()
	self._connection = nil
end

function class:destroy()
	local self = self :: InternalTypes.Hourglass
	if self.scope == nil then
		logError("destroyedTwice", nil, "Hourglass")
	end
	self.scope = nil
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
end

local function Hourglass(
	scope: Types.Scope<unknown>,
	interval: Types.CanBeState<number>?
): Types.Hourglass
    if scope == nil then
        logError("scopeMissing", nil, "Hourglass", "myScope:Hourglass(interval)")
    end
    -- apply defaults for tick interval
	if interval == nil then
		interval = .001
	end
	if typeof(peek(interval)) ~= "number" then
		logErrorNonFatal("mistypedHourglassInterval", nil, typeof(interval))
	elseif peek(interval) <= 0 then
		logErrorNonFatal("invalidHourglassInterval", nil, peek(interval))
	end

	local dependencySet: {[Types.Dependency]: unknown} = {}
	if isState(interval) then
		local interval = interval :: Types.StateObject<number>
		dependencySet[interval] = true
	end

	local self = setmetatable({
		scope = scope,
		dependencySet = dependencySet,
		dependentSet = {},
		_tickListeners = {},

		_interval = interval,
		_currentInterval = peek(interval),
		_nextTick = nil,
		_connection = nil
	}, CLASS_METATABLE)
	local self = (self :: any) :: InternalTypes.Hourglass

	table.insert(scope, self)

	if isState(interval) and interval.scope == nil then
		logError(
			"useAfterDestroy",
			nil,
			`The {interval.kind or interval.type or "interval"} object`,
			`the Hourglass`
		)
	elseif whichLivesLonger(scope, self, interval.scope, interval) == "definitely-a" then
		logWarn(
			"possiblyOutlives",
			`The {interval.kind or interval.type or "interval"} object`,
			`the Hourglass`
		)
	end

	-- add this object to the interval object's dependent set
	interval.dependentSet[self] = true

	return self
end

return Hourglass