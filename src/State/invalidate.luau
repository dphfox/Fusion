--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Invalidates a graph object, and transitively invalidates all of the graph
	objects' dependents.

	Note that this is guaranteed to succeed, even for cyclic graphs.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)

local function invalidate(
	target: Types.GraphObject
): ()
	if target.invalidation ~= "none" then
		-- If the target is directly invalidated, then we don't need to change
		-- anything.
		-- Similarly, if the target, is indirectly invalidated, then all we need
		-- to change is the target's invalidation, because the dependents are
		-- already transitively invalidated.
		target.invalidation = "direct"
		return
	end

	local noMoreDependents = true
	local invalidateNow: {Types.GraphObject} = {}
	local invalidateNext: {Types.GraphObject} = {}

	for dependent in target.dependentSet do
		noMoreDependents = false
		table.insert(invalidateNow, dependent)
	end
	if noMoreDependents then
		return
	end

	while true do
		noMoreDependents = true
		for _, dependent in invalidateNow do
			-- transitively or directly invalidated dependents are already fine
			if dependent.invalidation ~= "none" then
				continue
			end
			dependent.invalidation = "transitive"
			for subDependent in dependent.dependentSet do
				noMoreDependents = false
				table.insert(invalidateNext, subDependent)
			end
		end
		if noMoreDependents then
			return
		end
		invalidateNow, invalidateNext = invalidateNext, invalidateNow
		table.clear(invalidateNext)
	end
end

return invalidate