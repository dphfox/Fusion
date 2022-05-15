local Package = script.Parent.Parent

local messages = {
	strictReadError = "'%s' is not a valid member of '%s'.",
	unknownMessage = "Unknown error: ERROR_MESSAGE"
}

for _, library in ipairs(Package:GetChildren()) do
	if (library:FindFirstChild("Logging")) then
		if (library.Logging:FindFirstChild("messages")) then
			for messageID, message in pairs(require(library.Logging.messages)) do
				messages[messageID] = message
			end
		end
	end
end

return messages