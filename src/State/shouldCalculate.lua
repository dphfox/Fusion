--!nonstrict

--[[
	Returns a boolean suggesting whether or not to calculate the given dependent
	state's value.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local PubTypes = require(Package.PubTypes)
-- Utility
local xtypeof = require(Package.Utility.xtypeof)

local NEEDS_CALCULATION = {
	Observer = true,
}

local function shouldCalculate<T>(dependentState: Types.StateObject<T> & PubTypes.Dependent): boolean
	for subDependentState: Types.StateObject<any> & PubTypes.Dependent in dependentState.dependentSet :: any do
		if xtypeof(subDependentState) == "State" then
			if NEEDS_CALCULATION[subDependentState.kind] or shouldCalculate(subDependentState) then
				return true
			end
		end
	end
	return false
end

return shouldCalculate
