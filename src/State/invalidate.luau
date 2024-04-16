--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Invalidates a graph object, and transitively invalidates all of the graph
	objects' dependents.

	This is guaranteed to succeed, even for cyclic graphs.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)

local searchInNow: {Types.GraphObject} = {}
local searchInNext: {Types.GraphObject} = {}

local function invalidate(
	target: Types.GraphObject
): ()
	if not target.valid then
		table.clear(searchInNow)
		searchInNow[1] = target
		repeat
			table.clear(searchInNext)
			local done = true
			for _, searchTarget in searchInNow do
				for dependent in searchTarget.dependentSet do
					if dependent.valid then
						dependent.valid = false
						done = false
						table.insert(searchInNext, dependent)
					end
				end
			end
			searchInNow, searchInNext = searchInNext, searchInNow
		until done
	end
end

return invalidate