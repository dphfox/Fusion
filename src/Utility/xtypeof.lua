--!strict

--[[
	Extended typeof, designed for identifying custom objects.
	If given a table with a `type` field, returns that.
	Otherwise, returns `typeof()` the argument.
]]

local function xtypeof(x: any)
	local typeString = typeof(x)

	if typeString == "table" then
		return x.type or typeString
	else
		return typeString
	end
end

return xtypeof