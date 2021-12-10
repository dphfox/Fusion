--!strict

--[[
  Manages batch updating of delay objects.
]]

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent
local Types = require(Package.Types)
local updateAll = require(Package.Dependencies.updateAll)

type Array<T> = {[number]: T}
type Delay = Types.Delay<any>
type DelayData = {
  delay: Delay,
  start: number,
  duration: number,
  goal: any
}

local DelayScheduler = {}

local WEAK_KEYS_METATABLE = {__mode = "k"}

-- all delays to be updated
local allDelays: Array<DelayData> = {}
setmetatable(allDelays, WEAK_KEYS_METATABLE)

--[[
  Adds a Delay to be updated every render step.
]]
function DelayScheduler.add(delay: Delay)
  table.insert(allDelays, {
    delay = delay,
    start = os.clock(),
    duration = if delay._durationIsState then delay._duration:get(false) else delay._duration,
    goal = delay._nextValue
  })
end

--[[
  Removes a Delay from the scheduler.
]]
function DelayScheduler.remove(index: number)
  table.remove(allDelays, index)
end

--[[
  Updates all Delay objects.
]]
local function updateAllDelays()
  local now = os.clock()

  for index, delayObject in pairs(allDelays) do
    local delay = delayObject.delay
    local currentTime = now - delayObject.start
    
    if currentTime >= delayObject.duration then
      delay._currentValue = delayObject.goal
      updateAll(delay)
      DelayScheduler.remove(index)
    end
  end
end

RunService:BindToRenderStep(
  "__FusionDelayScheduler",
  Enum.RenderPriority.First.Value,
  updateAllDelays
)

return DelayScheduler