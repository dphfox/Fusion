--!strict
--!nolint LocalUnused
--!nolint LocalShadow
-- local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Utility function to log a Fusion-specific error, without halting execution.
]]

local Package = script.Parent.Parent
local InternalTypes = require(Package.InternalTypes)
local External = require(Package.External)
local messages = require(Package.Logging.messages)

local function logErrorNonFatal(
	messageID: string,
	errObj: InternalTypes.Error?,
	...: unknown
)	
	local formatString: string

	if messages[messageID] ~= nil then
		formatString = messages[messageID]
	else
		messageID = "unknownMessage"
		formatString = messages[messageID]
	end

	local errorString
	if errObj == nil then
		errorString = string.format("[Fusion] " .. formatString .. "\n(ID: " .. messageID .. ")", ...)
	else
		formatString = formatString:gsub("ERROR_MESSAGE", errObj.message)
		errorString = string.format("[Fusion] " .. formatString .. "\n(ID: " .. messageID .. ")\n---- Stack trace ----\n" .. errObj.trace, ...)
	end

	local errorString = errorString:gsub("\n", "\n    ")
	External.logErrorNonFatal(errorString)
end

return logErrorNonFatal