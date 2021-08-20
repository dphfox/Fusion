--[[
	Generates symbols used to denote property change handlers when working with
	the `New` function.
]]

local function OnChange(propertyName: string)
	return {
		type = "Symbol",
		name = "OnChange",
		key = propertyName
	}
end

return OnChange