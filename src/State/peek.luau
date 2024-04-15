--!strict
--!nolint LocalShadow

--[[
	A common interface for accessing the values of state objects or constants.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
-- State
local isState = require(Package.State.isState)

local function peek<T>(
	target: Types.CanBeState<T>
): T
	if isState(target) then
		return (target :: InternalTypes.StateObject<T>):_peek()
	else
		return target :: T
	end
end

return peek