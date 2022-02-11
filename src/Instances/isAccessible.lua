--!strict

--[[
	Returns true if an instance is considered 'accessible' - that is, a script
	could obtain a reference to an instance starting from the default instance
	globals (e.g. `game`, `script` and `plugin`).

	NOTE: The specific implementation of `isAccessible` does not handle some
	edge cases for performance reasons. Specifically, `isAccessible` only
	considers the hierarchical relationships between instances, and not
	references stored in instances like ObjectValues.

	This means that the only instances considered 'accessible' are those which
	are descendants of:

	- the data model containing `game`
	- the data model containing `script`
	- the data model containing `plugin`

	All other data models are not considered 'accessible' for simplicity.
]]

type Set<T> = {[T]: any}

local dataModels: Set<Instance> = {}
for _, descendant in ipairs({game, script, plugin}) do
	local root = descendant
	while root.Parent ~= nil do
		root = root.Parent
	end

	dataModels[root] = true
end

local function isAccessible(target: Instance): boolean
	for root in pairs(dataModels) do
		if root:IsAncestorOf(target) then
			return true
		end
	end
	return false
end

return isAccessible