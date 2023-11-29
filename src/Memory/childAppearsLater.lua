--!strict

--[[
	Checks the scope of the parent to see if the child will be destroyed before
	the parent is destroyed.
]]
local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logWarn = require(Package.Logging.logWarn)

local function childAppearsLaterImpl(
	haystack: {any},
	alreadyChecked: {[any]: true},
	parent: any,
	child: any
): boolean?
	for index = #haystack, 1, -1 do
		local value = haystack[index]
		if value == parent then
			return false
		elseif value == child then
			return true
		elseif typeof(value) == "table" and value[1] ~= nil and alreadyChecked[value] == nil then
			alreadyChecked[value] = true
			local appearsLater = childAppearsLaterImpl(value, alreadyChecked, parent, child)
			if appearsLater ~= nil then
				return appearsLater
			end
		end
	end
	return nil
end

local function childAppearsLater(
	scope: PubTypes.Scope<any>,
	parent: any,
	child: any
): boolean
	return childAppearsLaterImpl(scope, {}, parent, child) == true
end

return childAppearsLater