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
	if a == b then
		-- Tables that aren't frozen are assumed to be mutable, and mutable
		-- tables are assumed to always be dissimilar.
		return typeof(a) ~= "table" or table.isfrozen(a :: any) 
	else
		-- NaN is the only value that's similar to itself without being equal.
		return a ~= a and b ~= b
	end
end

return isSimilar
