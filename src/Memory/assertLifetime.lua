--!strict

--[[
	Checks the scope of the parent to see if the child will be destroyed before
	the parent is destroyed. If the parent is omitted, the scope will only be
	checked for presence of the child.
]]
local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)

local function assertLifetimeImpl(
	haystack: {any},
	alreadyChecked: {[any]: true},
	parent: any?,
	child: any
): boolean?
	for index = #haystack, 1, -1 do
		local value = haystack[index]
		if parent ~= nil and value == parent then
			return false
		elseif value == child then
			return true
		elseif typeof(value) == "table" and value[1] ~= nil and alreadyChecked[value] == nil then
			alreadyChecked[value] = true
			local appearsLater = assertLifetimeImpl(value, alreadyChecked, parent, child)
			if appearsLater ~= nil then
				return appearsLater
			end
		end
	end
	return nil
end

local function assertLifetime(
	scope: PubTypes.Scope<any>,
	parent: any?,
	child: any
): boolean
	return assertLifetimeImpl(scope, {}, parent, child) == true
end

return assertLifetime