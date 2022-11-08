--!strict

--[[
	Given a reactive object, updates all dependent reactive objects.
	Objects are only ever updated after all of their dependencies are updated,
	are only ever updated once, and won't be updated if their dependencies are
	unchanged.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)

type Set<T> = {[T]: any}
type Descendant = (PubTypes.Dependent & PubTypes.Dependency) | PubTypes.Dependent

local function updateAll(root: PubTypes.Dependency)
	local counters = {}
	local flags = {}
	local queue = {}

	-- Pass 1: counting up
	for object in root.dependentSet do
		table.insert(queue, object)
	end
	while #queue > 0 do
		local next = table.remove(queue, 1)
		counters[next] = (counters[next] or 0) + 1
		for object in next.dependentSet do
			table.insert(queue, object)
		end
	end

	-- Pass 2: counting down + processing
	for object in root.dependentSet do
		table.insert(queue, object)
		flags[object] = true
	end
	while #queue > 0 do
		local next = table.remove(queue, 1)
		counters[next] -= 1
		local setFlag = false
		if counters[next] == 0 and flags[next] then
			setFlag = next:update()
		end
		for object in next.dependentSet do
			table.insert(queue, object)
			if setFlag then
				flags[object] = true
			end
		end
	end
end

return updateAll