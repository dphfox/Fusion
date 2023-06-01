--!nonstrict

--[[
	Calculates a Computed or Eager's value.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
-- Logging
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local logWarn = require(Package.Logging.logWarn)
local parseError = require(Package.Logging.parseError)
-- Utility
local isSimilar = require(Package.Utility.isSimilar)
local needsDestruction = require(Package.Utility.needsDestruction)
-- State
local makeUseCallback = require(Package.State.makeUseCallback)

local function calculate<T>(computed: Types.Computed<T>): boolean
	-- remove this object from its dependencies' dependent sets
	for dependency in pairs(computed.dependencySet) do
		dependency.dependentSet[computed] = nil
	end

	-- we need to create a new, empty dependency set to capture dependencies
	-- into, but in case there's an error, we want to restore our old set of
	-- dependencies. by using this table-swapping solution, we can avoid the
	-- overhead of allocating new tables each update.
	computed._oldDependencySet, computed.dependencySet = computed.dependencySet, computed._oldDependencySet
	table.clear(computed.dependencySet)

	local use = makeUseCallback(computed.dependencySet)
	local ok, newValue, newMetaValue = xpcall(computed._processor, parseError, use)

	if ok then
		if computed._destructor == nil and needsDestruction(newValue) then
			logWarn(`destructorNeeded{computed.kind}`)
		end

		if newMetaValue ~= nil then
			logWarn(`multiReturn{computed.kind}`)
		end

		local oldValue = computed._value
		local similar = isSimilar(oldValue, newValue)
		if computed._destructor ~= nil then
			computed._destructor(oldValue)
		end
		computed._value = newValue

		-- add this object to the dependencies' dependent sets
		for dependency in pairs(computed.dependencySet) do
			dependency.dependentSet[computed] = true
		end

		return not similar
	else
		-- this needs to be non-fatal, because otherwise it'd disrupt the
		-- update process
		logErrorNonFatal(`{computed.kind:lower()}CallbackError`, newValue)

		-- restore old dependencies, because the new dependencies may be corrupt
		computed._oldDependencySet, computed.dependencySet = computed.dependencySet, computed._oldDependencySet

		-- restore this object in the dependencies' dependent sets
		for dependency in pairs(computed.dependencySet) do
			dependency.dependentSet[computed] = true
		end

		return false
	end
end

return calculate
