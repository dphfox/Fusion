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
-- State
local castToState = require(Package.State.castToState)
-- Graph
local evaluate = require(Package.Graph.evaluate)

local function peek<T>(
	target: Types.UsedAs<T>
): T
	local targetState = castToState(target)
	if targetState ~= nil then
		evaluate(targetState, false)
		return targetState._EXTREMELY_DANGEROUS_usedAsValue :: T
	else
		return target :: T
	end
end

return peek