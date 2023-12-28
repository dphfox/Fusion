--!strict
--!nolint LocalShadow

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
	if External.unitTestSilenceNonFatal then
		return
	end
	
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

	coroutine.wrap(function()
		error(errorString:gsub("\n", "\n    "), 0)
	end)()
end

return logErrorNonFatal