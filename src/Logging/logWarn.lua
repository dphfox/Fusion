--!strict
--!nolint LocalShadow

--[[
	Utility function to log a Fusion-specific warning.
]]

local Package = script.Parent.Parent
local messages = require(Package.Logging.messages)

local function logWarn(
	messageID: string,
	...: unknown
)
	local formatString: string

	if messages[messageID] ~= nil then
		formatString = messages[messageID]
	else
		messageID = "unknownMessage"
		formatString = messages[messageID]
	end

	local warnMessage = string.format("[Fusion] " .. formatString .. "\n(ID: " .. messageID .. ")", ...)
	warnMessage ..=  "\n---- Stack trace ----\n" .. debug.traceback(nil, 3)
	warn(warnMessage)
end

return logWarn