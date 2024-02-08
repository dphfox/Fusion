--!strict
--!nolint LocalShadow

--[[
	Returns true if the given value is not automatically memory managed, and
	requires manual cleanup.
]]

local function needsDestruction(
	x: unknown
): boolean
	return typeof(x) == "Instance"
end

return needsDestruction