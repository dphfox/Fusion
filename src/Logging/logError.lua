--!strict
--!nolint LocalShadow

--[[
	Utility function to log a Fusion-specific error.
]]

local Package = script.Parent.Parent
local InternalTypes = require(Package.InternalTypes)
local messages = require(Package.Logging.messages)

local function logError(
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

	error(errorString:gsub("\n", "\n    "), 0)
end

return logError