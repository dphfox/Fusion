--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

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