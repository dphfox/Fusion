--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Returns the input *only* if it is a state object.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)

local function castToState<T>(
	target: Types.UsedAs<T>
): Types.StateObject<T>?
	if
		typeof(target) == "table" and
		target.type == "State" 
	then
		return target
	else
		return nil
	end
end

return castToState