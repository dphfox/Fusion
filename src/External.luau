--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Abstraction layer between Fusion internals and external environments,
	allowing for flexible integration with schedulers and test mocks.
]]

local Package = script.Parent
<<<<<<< HEAD
local logError = require(Package.Logging.logError)

local External = {}

export type Scheduler = {
	doTaskImmediate: (
		resume: () -> ()
	) -> (),
	doTaskDeferred: (
		resume: () -> ()
	) -> (),
	errorNonFatal: (
		err: unknown
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
=======
local formatError = require(Package.Logging.formatError)
local Types = require(Package.Types)

local ERROR_INFO_URL = "https://elttob.uk/Fusion/0.3/api-reference/general/errors/#"

local External = {}

local updateStepCallbacks = {}
local currentProvider: Types.ExternalProvider? = nil
local lastUpdateStep = 0

--[[
	Swaps to a new provider for external operations.
	Returns the old provider, so it can be used again later.
]]
function External.setExternalProvider(
	newProvider: Types.ExternalProvider?
): Types.ExternalProvider?
	local oldProvider = currentProvider
	if oldProvider ~= nil then
		oldProvider.stopScheduler()
	end
	currentProvider = newProvider
	if newProvider ~= nil then
		newProvider.startScheduler()
	end
	return oldProvider
end

--[[
   Sends an immediate task to the external provider. Throws if none is set.
>>>>>>> upstream/main
]]
function External.doTaskImmediate(
	resume: () -> ()
)
<<<<<<< HEAD
	if currentScheduler == nil then
		logError("noTaskScheduler")
	else
		currentScheduler.doTaskImmediate(resume)
=======
	if currentProvider == nil then
		formatError(currentProvider, "noTaskScheduler")
	else
		currentProvider.doTaskImmediate(resume)
>>>>>>> upstream/main
	end
end

--[[
<<<<<<< HEAD
	Sends a deferred task to the external scheduler. Throws if none is set.
=======
	Sends a deferred task to the external provider. Throws if none is set.
>>>>>>> upstream/main
]]
function External.doTaskDeferred(
	resume: () -> ()
)
<<<<<<< HEAD
	if currentScheduler == nil then
		logError("noTaskScheduler")
	else
		currentScheduler.doTaskDeferred(resume)
=======
	if currentProvider == nil then
		formatError(currentProvider, "noTaskScheduler")
	else
		currentProvider.doTaskDeferred(resume)
>>>>>>> upstream/main
	end
end

--[[
<<<<<<< HEAD
	Errors in a different thread to preserve the flow of execution.
]]
function External.errorNonFatal(
	err: unknown
)
	if currentScheduler == nil then
		logError("noTaskScheduler")
	else
		currentScheduler.errorNonFatal(err)
=======
	Errors in the current thread and halts execution.
]]
function External.logError(
	messageID: string,
	errObj: Types.Error?,
	...: unknown
): never
	error(formatError(currentProvider, messageID, errObj, ...), 0)
end

--[[
	Errors in a different thread to preserve the flow of execution.
]]
function External.logErrorNonFatal(
	messageID: string,
	errObj: Types.Error?,
	...: unknown
): ()
	local errorString = formatError(currentProvider, messageID, errObj, ...)
	if currentProvider ~= nil then
		currentProvider.logErrorNonFatal(errorString)
	else
		print(errorString)
>>>>>>> upstream/main
	end
end

--[[
<<<<<<< HEAD
	Registers a callback to the update step of the external scheduler.
=======
	Shows a warning message in the output.
]]
function External.logWarn(
	messageID: string,
	...: unknown
): ()
	local errorString = formatError(currentProvider, messageID, debug.traceback(nil, 2), ...)
	if currentProvider ~= nil then
		currentProvider.logWarn(errorString)
	else
		print(errorString)
	end
end

--[[
	Registers a callback to the update step of the external provider.
>>>>>>> upstream/main
	Returns a function that can be used to disconnect later.

	Callbacks are given the current number of seconds since an arbitrary epoch.
	
<<<<<<< HEAD
	TODO: This epoch may change between schedulers. We could investigate ways
	of allowing schedulers to co-operate to keep the epoch the same, so that
=======
	TODO: This epoch may change between providers. We could investigate ways
	of allowing providers to co-operate to keep the epoch the same, so that
>>>>>>> upstream/main
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
<<<<<<< HEAD
	scheduler's update cycle.
=======
	provider's update cycle.
>>>>>>> upstream/main
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