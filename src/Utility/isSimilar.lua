--!strict
--!nolint LocalShadow

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
	else
		-- NaN does not equal itself but is the same
		return a == b or a ~= a and b ~= b
	end
end

return isSimilar
