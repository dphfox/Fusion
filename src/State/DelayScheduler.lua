--!strict

--[[
  Manages batch updating of delay objects.
]]

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent
local Types = require(Package.Types)
local updateAll = require(Package.Dependencies.updateAll)

type Set<T> = {[T]: any}
type Delay = Types.Delay<any>
type DelayData = {
  delay: Delay,
  start: number,
  duration: number,
  goal: any
}

local DelayScheduler = {}

-- all delays to be updated
local allDelays: Set<DelayData> = {}

--[[
  Adds a Delay to be updated every render step.
]]
function DelayScheduler.add(delay: Delay)
  allDelays[{
    delay = delay,
    start = os.clock(),
    duration = if delay._durationIsState then delay._duration:get(false) else delay._duration,
    goal = delay._nextValue
  }] = true
end

--[[
  Removes a Delay from the scheduler.
]]
function DelayScheduler.remove(delayData: DelayData)
  allDelays[delayData] = nil
end

--[[
  Updates all Delay objects.
]]
local function updateAllDelays()
  local now = os.clock()

  for delayObject in pairs(allDelays) do
    local delay = delayObject.delay
    local currentTime = now - delayObject.start
    
    if currentTime >= delayObject.duration then
      delay._currentValue = delayObject.goal
      updateAll(delay)
      DelayScheduler.remove(delayObject)
    end
  end
end

RunService:BindToRenderStep(
  "__FusionDelayScheduler",
  Enum.RenderPriority.First.Value,
  updateAllDelays
)

return DelayScheduler