--!strict

--[[
	Generates symbols used to denote property change handlers when working with
	the `New` function.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)

local function OnChange(propertyName: string): Types.OnChangeKey
	return {
		type = "Symbol",
		name = "OnChange",
		key = propertyName
	}
end

return OnChange