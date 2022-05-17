--!strict

--[[
	The entry point for the Fusion library.
]]

local restrictRead = require(script.Core.Utility.restrictRead)

local libraries = {}

for _, Library in ipairs(script:GetChildren()) do
	if Library:IsA("ModuleScript") then
		libraries[Library.Name] = require(Library)
	end
end

return restrictRead("Fusion", libraries)