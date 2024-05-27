--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

local Package = script.Parent.Parent
<<<<<<< HEAD
local logWarn = require(Package.Logging.logWarn)
local doCleanup = require(Package.Memory.doCleanup)

local function legacyCleanup(
	...: unknown
)
	logWarn("cleanupWasRenamed")
	return doCleanup(...)
=======
local Types = require(Package.Types)
local External = require(Package.External)
local doCleanup = require(Package.Memory.doCleanup)

local function legacyCleanup(
	value: Types.Task
)
	External.logWarn("cleanupWasRenamed")
	return doCleanup(value)
>>>>>>> upstream/main
end

return legacyCleanup