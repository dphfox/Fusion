--!strict

--[[
	The entry point for the Fusion library.
]]

local restrictRead = require(script.Utility.restrictRead)

local libraries = {};

for _, library in ipairs(script:GetChildren()) do
	if (library:IsA("ModuleScript") and (library.Name ~= "PubTypes") and (library.Name ~= "Types")) then
		libraries[library.Name] = require(library);
	end
end

return restrictRead("Fusion", libraries)