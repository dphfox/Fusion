--!strict

--[[
	Counts the length of values in an array/dictionary.
]]

local function lengthOf(t: { [any]: any }): number
	local index = 0

	for _ in t do
		index += 1
	end

	return index
end

return lengthOf
