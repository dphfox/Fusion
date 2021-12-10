--!strict

--[[
  Constructs a new delay object which wraps a value object
  and delays its updates
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local DelayScheduler = require(Package.State.DelayScheduler)
local useDependency = require(Package.Dependencies.useDependency)
local initDependency = require(Package.Dependencies.initDependency)

local class = {}

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}

--[[
  Returns the value of the wrapped value object
  based on delay
]]
function class:get(asDependency: boolean?): any
  if asDependency ~= false then
    useDependency(self)
  end
  return self._currentValue
end

--[[
  Called when the wrapped value object changes value, or when the
  delay duration has changed.

  For value object changes:

  The delay object will be added with the new value to the scheduler.

  For duration changes:

  Existing value updates in the scheduler will be remain enqueued with
  their previous duration and any updates after this duration change will
  be added to the scheduler with the new delay.
]]
function class:update(): boolean
  self._nextValue = self._valueState:get(false)

  DelayScheduler.add(self)

  return false
end

local function Delay<T>(valueState: PubTypes.Value<T>, delayDuration: PubTypes.CanBeState<number>)
  local currentValue = valueState:get(false)
  
  local dependencySet = {[valueState] = true}
  local delayIsState = typeof(delayDuration) == "table" and delayDuration.type == "State"
  
  if delayIsState then
    dependencySet[delayDuration] = true
  end

  local self = setmetatable({
    type = "State",
    kind = "Delay",
    dependencySet = dependencySet,
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
    dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),

    _valueState = valueState,
    _nextValue = currentValue,
    _currentValue = currentValue,

    _duration = delayDuration,
    _durationIsState = delayIsState,
  }, CLASS_METATABLE)

  initDependency(self)
  -- add this object to the value state's dependent set
  valueState.dependentSet[self] = true

  return self
end

return Delay