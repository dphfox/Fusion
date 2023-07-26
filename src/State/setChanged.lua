--!nonstrict

--[[
	Sets the given `dependentState` and dependents `didChange` value to true.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local PubTypes = require(Package.PubTypes)
-- Utility
local isDependentState = require(Package.State.isDependentState)

local function setChanged(dependentState: Types.StateObject<any> & PubTypes.Dependent)
	dependentState.didChange = true
	for subDependentState in dependentState.dependentSet do
		if isDependentState(subDependentState) then
			setChanged(subDependentState)
		end
	end
end

return setChanged