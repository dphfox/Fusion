--!strict
--[[
    Abstraction layer between Fusion internals and external environments,
    allowing for flexible integration with schedulers and test mocks.
]]

local Package = script.Parent
local logError = require(Package.Logging.logError)

local External = {}

export type Scheduler = {
    doTaskImmediate: (
        resume: () -> ()
    ) -> (),
    doTaskDeferred: (
        resume: () -> ()
    ) -> (),
    startScheduler: () -> (),
    stopScheduler: () -> ()
}

local updateStepCallbacks = {}
local currentScheduler: Scheduler? = nil
local lastUpdateStep = 0

--[[
    Sets the external scheduler that Fusion will use for queuing async tasks.
    Returns the previous scheduler so it can be reset later.
]]
function External.setExternalScheduler(
    newScheduler: Scheduler?
): Scheduler?
    local oldScheduler = currentScheduler
    if oldScheduler ~= nil then
        oldScheduler.stopScheduler()
    end
    currentScheduler = newScheduler
    if newScheduler ~= nil then
        newScheduler.startScheduler()
    end
    return oldScheduler
end

--[[
   Sends an immediate task to the external scheduler. Throws if none is set.
]]
function External.doTaskImmediate(
    resume: () -> ()
)
    if currentScheduler == nil then
        logError("noTaskScheduler")
    else
        currentScheduler.doTaskImmediate(resume)
    end
end

--[[
    Sends a deferred task to the external scheduler. Throws if none is set.
]]
function External.doTaskDeferred(
    resume: () -> ()
)
    if currentScheduler == nil then
        logError("noTaskScheduler")
    else
        currentScheduler.doTaskDeferred(resume)
    end
end

--[[
    Registers a callback to the update step of the external scheduler.
    Returns a function that can be used to disconnect later.

    Callbacks are given the current number of seconds since an arbitrary epoch.
    
    TODO: This epoch may change between schedulers. We could investigate ways
    of allowing schedulers to co-operate to keep the epoch the same, so that
    monotonicity can be better preserved.
]]
function External.bindToUpdateStep(
    callback: (
        now: number
    ) -> ()
): () -> ()
    local uniqueIdentifier = {}
    updateStepCallbacks[uniqueIdentifier] = callback
    return function()
        updateStepCallbacks[uniqueIdentifier] = nil
    end
end

--[[
    Steps time-dependent systems with the current number of seconds since an
    arbitrary epoch. This should be called as early as possible in the external
    scheduler's update cycle.
]]
function External.performUpdateStep(
    now: number
)
    lastUpdateStep = now
    for _, callback in updateStepCallbacks do
        callback(now)
    end
end

--[[
    Returns the timestamp of the last update step.
]]
function External.lastUpdateStep()
    return lastUpdateStep
end

return External