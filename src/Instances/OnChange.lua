--!strict

--[[
	Generates symbols used to denote property change handlers when working with
	the `New` function.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)

local function OnChange(propertyName: string): PubTypes.OnChangeKey
	return {
		type = "Symbol",
		name = "OnChange",
		key = propertyName
	}
end

return OnChange