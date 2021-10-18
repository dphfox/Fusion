--!strict

--[[
	A symbol for representing nil values in contexts where nil is not usable.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)

return {
	type = "Symbol",
	name = "None"
} :: PubTypes.None