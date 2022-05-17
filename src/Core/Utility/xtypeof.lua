--!strict

--[[
	Extended typeof, designed for identifying custom objects.
	If given a table with a `type` string, returns that.
	Otherwise, returns `typeof()` the argument.
]]

local function xtypeof(x: any)
	local typeString = typeof(x)

	if typeString == "table" and typeof(x.type) == "string" then
		return x.type
	else
		return typeString
	end
end

return xtypeof