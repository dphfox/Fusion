--!strict

--[[
	Returns true if the given value can be assumed to be a valid dependent state
	object.
]]

local Package = script.Parent.Parent
-- Utility
local isState = require(Package.State.isState)

local function isDependentState(target: any): boolean
	return isState(target)
		and typeof(target.dependencySet) == "table"
		and typeof(target.didChange) == "boolean"
		and typeof(target.update) == "function"
end

return isDependentState