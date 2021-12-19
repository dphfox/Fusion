--!strict

--[[
	The symbol used to denote the reference of an instance when working with the
	`New` function.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)

return {
	type = "Symbol",
	name = "Ref"
} :: PubTypes.RefKey