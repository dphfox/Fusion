--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Forms a dependency on a graph object.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local evaluate = require(Package.State.evaluate)

local function depend<T>(
	dependent: Types.GraphObject,
	dependency: Types.GraphObject
): ()
	if dependency.lastChange == nil then
		-- Newly created objects might not have any transitive dependencies
		-- captured yet, so ensure that they're present.
		evaluate(dependency)
	end
	dependency.dependentSet[dependent] = true
	dependent.dependencySet[dependency] = true
end

return depend