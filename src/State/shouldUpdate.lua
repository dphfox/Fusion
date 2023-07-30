--!nonstrict

--[[
	Returns a boolean suggesting whether or not to update the given dependent
	state's value.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local PubTypes = require(Package.PubTypes)
-- Utility
local xtypeof = require(Package.Utility.xtypeof)

local REQUIRES_UPDATE = {
	Observer = true,
}

local function shouldUpdate<T>(dependentState: Types.StateObject<T> & PubTypes.Dependent): boolean
	for subDependentState: Types.StateObject<any> & PubTypes.Dependent in dependentState.dependentSet :: any do
		if xtypeof(subDependentState) == "State" then
			if REQUIRES_UPDATE[subDependentState.kind] or shouldUpdate(subDependentState) then
				return true
			end
		end
	end
	return false
end

return shouldUpdate
