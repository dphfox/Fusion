--!strict
--!nolint LocalUnused
--!nolint LocalShadow
-- local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Utility function to log a Fusion-specific error, without halting execution.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
local formatError = require(Package.Logging.formatError)

local ERROR_INFO_URL = "https://elttob.uk/Fusion/0.3/api-reference/general/errors/#"

local function logErrorNonFatal(
	messageID: string,
	errObj: Types.Error?,
	...: unknown
): ()
	External.errorNonFatal(formatError(messageID, errObj, ...))
end

return logErrorNonFatal