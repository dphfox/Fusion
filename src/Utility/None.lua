--!strict

--[[
	A symbol for representing nil values in contexts where nil is not usable.
]]

local Package = script.Parent.Parent
local LibTypes = require(Package.LibTypes)

return {
	type = "Symbol",
	name = "None"
} :: LibTypes.None