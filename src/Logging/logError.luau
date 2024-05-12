--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Utility function to log a Fusion-specific error.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local formatError = require(Package.Logging.formatError)

local function logError(
	messageID: string,
	errObj: Types.Error?,
	...: unknown
): never
	error(formatError(messageID, errObj, ...), 0)
end

return logError