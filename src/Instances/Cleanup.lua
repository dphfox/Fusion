--!strict

--[[
	The symbol used to denote what should be cleaned up when an instance created
    with the `New` function is destroyed
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)

return {
	type = "Symbol",
	name = "Cleanup"
} :: PubTypes.CleanupKey