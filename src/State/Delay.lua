--!strict

--[[
  Constructs a new delay object which wraps a value object
  and delays its updates
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local useDependency = require(Package.Dependencies.useDependency)
local initDependency = require(Package.Dependencies.initDependency)
local updateAll = require(Package.Dependencies.updateAll)

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
  Called when the wrapped value object changes value.

  The delay object will begin a new coroutine that will
  be delayed in execution by the delay's duration.
]]
function class:update(): boolean
  local goal = self._valueState:get(false)

  task.delay(
    self._duration,
    function()
      self._currentValue = goal
      updateAll(self)
    end
  )
  
  return false
end

local function Delay<T>(valueState: PubTypes.StateObject<T>, delayDuration: number)
  local currentValue = valueState:get(false)
  local dependencySet = {[valueState] = true}

  local self = setmetatable({
    type = "State",
    kind = "Delay",
    dependencySet = dependencySet,
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
    dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),

    _valueState = valueState,
    _currentValue = currentValue,

    _duration = delayDuration
  }, CLASS_METATABLE)

  initDependency(self)
  -- add this object to the value state's dependent set
  valueState.dependentSet[self] = true

  return self
end

return Delay