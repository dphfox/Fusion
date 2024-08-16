--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Abstraction layer between Fusion internals and external environments,
	allowing for flexible integration with schedulers and test mocks.
]]

local Package = script.Parent
local formatError = require(Package.Logging.formatError)
local Types = require(Package.Types)

local ERROR_INFO_URL = "https://elttob.uk/Fusion/0.3/api-reference/general/errors/#"

local External = {}

-- Indicates that a highly time-critical passage of code is running. During
-- critical periods of a program, Fusion might decide to change some of its
-- internal behaviour to be more performance friendly.
local timeCritical = false

-- Multiplier for running-time safety checks across the Fusion codebase. Used to
-- stricten tests on infinite loop detection during unit testing.
External.safetyTimerMultiplier = 1

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
	Returns true if a highly time-critical passage of code is running.
]]
function External.isTimeCritical(): boolean
	return timeCritical
end

--[[
   Sends an immediate task to the external provider. Throws if none is set.
]]
function External.doTaskImmediate(
	resume: () -> ()
)
	if currentProvider == nil then
		External.logError("noTaskScheduler")
	else
		currentProvider.doTaskImmediate(resume)
	end
end

--[[
	Sends a deferred task to the external provider. Throws if none is set.
]]
function External.doTaskDeferred(
	resume: () -> ()
)
	if currentProvider == nil then
		External.logError("noTaskScheduler")
	else
		currentProvider.doTaskDeferred(resume)
	end
end

--[[
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
	end
end

--[[
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
	Returns a function that can be used to disconnect later.

	Callbacks are given the current number of seconds since an arbitrary epoch.
	
	TODO: This epoch may change between providers. We could investigate ways
	of allowing providers to co-operate to keep the epoch the same, so that
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
	provider's update cycle.
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