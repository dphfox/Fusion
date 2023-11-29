--!strict

--[[
	Given one argument, checks if the argument is destroyed by this scope.
	Given two arguments, checks if the first argument is destroyed before the
	second argument by this scope.
]]
local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)

local function assertLifetimeImpl(
	haystack: {any},
	alreadyChecked: {[any]: true},
	destroyedFirst: any,
	destroyedSecond: any?
): boolean?
	for index = #haystack, 1, -1 do
		local value = haystack[index]
		if destroyedSecond ~= nil and value == destroyedSecond then
			return false
		elseif value == destroyedFirst then
			return true
		elseif typeof(value) == "table" and value[1] ~= nil and alreadyChecked[value] == nil then
			alreadyChecked[value] = true
			local appearsLater = assertLifetimeImpl(value, alreadyChecked, destroyedFirst, destroyedSecond)
			if appearsLater ~= nil then
				return appearsLater
			end
		end
	end
	return nil
end

local function assertLifetime(
	scope: PubTypes.Scope<any>,
	destroyedFirst: any,
	destroyedSecond: any?
): boolean
	return assertLifetimeImpl(scope, {}, destroyedFirst, destroyedSecond) == true
end

return assertLifetime