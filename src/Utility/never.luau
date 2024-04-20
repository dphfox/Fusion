--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Never returns.
]]

local function never(): never
	error("This codepath should not be reachable")
end

return never