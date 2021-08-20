--[[
	Utility function to log a Fusion-specific warning.
]]

local Package = script.Parent.Parent
local messages = require(Package.Logging.messages)

local function logWarn(template, ...)
	local formatString = messages[template]

	if formatString == nil then
		template = "unknownMessage"
		formatString = messages[template]
	end

	warn(string.format("[Fusion] " .. formatString .. "\n(ID: " .. template .. ")", ...))
end

return logWarn