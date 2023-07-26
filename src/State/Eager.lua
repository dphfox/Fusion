--!nonstrict

--[[
	A state object wrapper to force an already existing dependent state to update
	eagerly.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local PubTypes = require(Package.PubTypes)

local function Eager<T>(dependentState: Types.StateObject<T> & PubTypes.Dependent): Types.StateObject<T> & PubTypes.Dependent
	local updateDependentState = dependentState.update
	dependentState.update = function()
		return updateDependentState(dependentState, true)
	end

	-- if we didn't check if the dependent state changed it could lead to an
	-- unnecessary update
	if dependentState.didChange then
		dependentState:update()
	end
	return dependentState
end

return Eager
