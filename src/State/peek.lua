--!strict

--[[
	A common interface for accessing the values of state objects or constants.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Types = require(Package.Types)
-- State
local isState = require(Package.State.isState)

local function peek<T>(target: PubTypes.CanBeState<T>): T
	if isState(target) then
		return (target :: Types.StateObject<T>):_peek()
	else
		return target
	end
end

return peek