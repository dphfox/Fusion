--!strict
--!nolint LocalShadow

local Package = script.Parent.Parent
local logWarn = require(Package.Logging.logWarn)
local doCleanup = require(Package.Memory.doCleanup)

local function legacyCleanup(
	...: unknown
)
	logWarn("cleanupWasRenamed")
	return doCleanup(...)
end

return legacyCleanup