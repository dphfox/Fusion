--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Extended typeof, designed for identifying custom objects.
	If given a table with a `type` string, returns that.
	Otherwise, returns `typeof()` the argument.
]]

local function xtypeof(
	x: unknown
): string
	local typeString = typeof(x)

	if typeString == "table" then
		local x = x :: {type: unknown?}
		if typeof(x.type) == "string" then
			return x.type
		end
	end

	return typeString
end

return xtypeof