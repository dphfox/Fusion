--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Extracts a value of type T from its input.

	https://elttob.uk/Fusion/0.3/api-reference/state/members/peek/
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
-- State
local isState = require(Package.State.isState)
local evaluate = require(Package.State.evaluate)

local function peek<T>(
	target: Types.UsedAs<T>
): T
	if isState(target) then
		local target = target :: InternalTypes.StateObject<T>
		evaluate(target)
		return target:_peek()
	else
		return target :: T
	end
end

return peek