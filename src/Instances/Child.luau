--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Right now, if you construct a list of items that aren't the same type, Luau raises a type checking error,
    even if the list is being placed into a variable explicitly typed to accept those items as part of a union.

    This function here solves this by passing through the values of Children and casting it to the proper type.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)

local function Child(
    x: {Types.Child}
): Types.Child
    return x
end

return Child