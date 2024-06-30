--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Returns the input *only* if it is a graph object.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)

local function castToGraph(
	target: any
): Types.GraphObject?
	if 
		typeof(target) == "table" and
		typeof(target.validity) == "string" and
		typeof(target.timeliness) == "string" and
		typeof(target.dependencySet) == "table" and
		typeof(target.dependentSet) == "table"
	then
		return target
	else
		return nil
	end
end

return castToGraph