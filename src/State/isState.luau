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
		local target = target :: {_peek: unknown?}
		return typeof(target._peek) == "function"
	end
	return false
end

return isState