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
	local typeA = typeof(a)
	local isTable = typeA == "table"
	local isUserdata = typeA == "userdata"
	return
		if not (isTable or isUserdata) then
			-- Fast path for everything that doesn't have a metatable.
			-- NaN is the only value that's similar without being equal.
			-- NaN may also appear as a component of the type, e.g. vectors
			a == b or a ~= a and b ~= b
		elseif typeA == typeof(b) and (table.isfrozen(a :: any) or getmetatable(a :: any) ~= nil or isUserdata) then
			-- Simple equality for userdatas, frozen tables, or possible __eq
			-- Unfortunately, __eq may not be accessible from locked metatables.
			-- As a simple heuristic, use == if a metatable is found to try and
			-- respect it (even if this returns true for non-similar things)
			a == b
		else
			-- Either a mutable table (dissimilar by definition)
			-- Or, different types:
			-- 1) can never be == or rawequal()
			-- 2) never have __eq evaluated even with identical __eq methods
			-- 3) can never be NaN
			false
end

return isSimilar
