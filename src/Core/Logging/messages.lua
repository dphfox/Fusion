local Package = script.Parent.Parent.Parent
local Core = script.Parent.Parent

local messages = {
	computedCallbackError = "Computed callback error: ERROR_MESSAGE",
	strictReadError = "'%s' is not a valid member of '%s'.",
	unknownMessage = "Unknown error: ERROR_MESSAGE"
}

for _, Library in ipairs(Package:GetChildren()) do
	if (Library ~= Core) and (Library:FindFirstChild("Logging")) then
		if (Library.Logging:FindFirstChild("messages")) then
			for messageID, message in pairs(require(Library.Logging.messages)) do
				messages[messageID] = message
			end
		end
	end
end

return messages