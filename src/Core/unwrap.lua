--!strict

--[[
	A common interface for accessing the values of state objects or constants.
]]

local Package = script.Parent
local PubTypes = require(Package.PubTypes)
local xtypeof = require(Package.Utility.xtypeof)

local function unwrap<T>(item: PubTypes.CanBeState<T>, useDependency: boolean?): T
	return if xtypeof(item) == "State" then (item :: PubTypes.StateObject<T>):get(useDependency) else (item :: T)
end

return unwrap