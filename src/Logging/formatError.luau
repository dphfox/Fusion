--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Formats a Fusion-specific error message.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local messages = require(Package.Logging.messages)

local ERROR_INFO_URL = "https://elttob.uk/Fusion/0.3/api-reference/general/errors/#"

local function formatError(
	externalProvider: Types.ExternalProvider?,
	messageID: string,
	errorOrTrace: Types.Error | string | nil,
	...: unknown
): string
	local originalMessageID = messageID
	local error: Types.Error? = if typeof(errorOrTrace) == "table" then errorOrTrace else nil
	local trace: string? = if typeof(errorOrTrace) == "table" then errorOrTrace.trace else errorOrTrace
	local messageText = messages[messageID]
	if messageText == nil then
		messageID = "unknownMessage"
		messageText = messages[messageID]
	end
	messageText = messageText:format(...)
	if error ~= nil then
		messageText = messageText:gsub("ERROR_MESSAGE", error.message)
		if error.context ~= nil then
			messageText ..= ` ({error.context})`
		end
	else
		messageText = messageText:gsub("ERROR_MESSAGE", originalMessageID)
	end
	messageText = `[Fusion] {messageText} \nID: {messageID}`
	if externalProvider ~= nil and externalProvider.policies.allowWebLinks then
		messageText ..= `\nLearn more: {ERROR_INFO_URL}{messageID:lower()}`
	end
	if trace ~= nil then
		messageText ..= ` \n---- Stack trace ----\n{trace}`
	end
	return messageText:gsub("\n", "\n    ")
end

return formatError