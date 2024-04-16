--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Returns true if A and B are 'similar' - i.e. any user of A would not need
	to recompute if it changed to B.
]]

local function isSimilar(
	a: unknown, 
	b: unknown
): boolean
	-- HACK: because tables are mutable data structures, don't make assumptions
	-- about similarity from equality for now (see issue #44)
	if typeof(a) == "table" then
		return false
	elseif a == b then
		return true
	elseif a ~= a and b ~= b then
		-- NaN does not equal itself but is the same
		return true
	else
		return false
	end
end

return isSimilar
