--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Helper function for type checking purposes. Casts the input to a `Child`
	type, while constraining the input to be an array of `Child` - this prevents
	Luau from erroneously inferring a different array type for the input.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)

local function Child(
	x: {Types.Child}
): Types.Child
	return x
end

return Child
