--!strict

--[[
	The symbol used to denote the children of an instance when working with the
	`New` function.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)

return {
	type = "Symbol",
	name = "Children"
} :: Types.ChildrenKey