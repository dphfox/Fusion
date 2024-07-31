--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Stores nicknames for values that don't support metatables, so that `nameOf`
	can return values for them.
]]

return setmetatable({}, {__mode = "k"})