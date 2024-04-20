--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Returns true if the given value can be assumed to be a valid state object.
]]

local function isState(
	target: unknown
): boolean
	if typeof(target) == "table" then
		return (target :: any).type == "State"
	end
	return false
end

return isState