--!nonstrict

--[[
	Constructs a new GenericFor object which maps pairs of a table using
	a `processor` function.

	Optionally, a `destructor` function can be specified for cleaning up values.
	If omitted, the default cleanup function will be used instead.

	Additionally, a `meta` table/value can optionally be returned to pass data created
	when running the processor to the destructor when the created object is cleaned up.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Types = require(Package.Types)
-- Logging
local parseError = require(Package.Logging.parseError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local logError = require(Package.Logging.logError)
local logWarn = require(Package.Logging.logWarn)
-- Utility
local cleanup = require(Package.Utility.cleanup)
local doNothing = require(Package.Utility.doNothing)
local needsDestruction = require(Package.Utility.needsDestruction)
-- State
local Computed = require(Package.State.Computed)
local peek = require(Package.State.peek)
local isState = require(Package.State.isState)

local class = {}

local CLASS_METATABLE = { __index = class }
local WEAK_KEYS_METATABLE = { __mode = "k" }

type ComputedEntry = {
	key: any,
	value: any,
	intermediateKey: Types.Computed<any>,
	intermediateValue: Types.Computed<any>,
	final: Types.Computed<{any}>,

	newDependencies: {[Types.StateObject<any>]: true},
	oldDependencies: {[Types.StateObject<any>]: true},
	oldResult: {any},
}

--[[
	Called when the original table is changed.

	It will first check for key-value pairs with only a key or only a value changed.
	Those that are found will have either their key or their value modified.
	Any old key-value pairs that are disjoint from every new key-value pair will be removed and destructed.
	Any new key-value pair will get a new ComputedEntry made for it.

	A ComputedEntry contains the key, value, some tables for caching, and three Computeds.

	The two intermediate Computeds will call `use` on self, making them update after this function.
	They will return either the key or the value stored in the ComputedEntry.

	The final Computed will run the processor, passing in both of the intermediate Computeds.
	It will return the results in an array.
	This Computed handles destruction, passing the old outputs into the destructor using Computed's destructor.

	Note that calling peek on self will only return the dictionary of ComputedEntries.
	This is because self is not actually returned in the constructor; it only acts as a dependent for internal Computeds.
	The constructor instead returns a Computed that combines the dictionary of ComputedEntries into one final result.
]]
function class:update(): boolean
	local inputIsState = self._inputIsState
	local newInputTable = peek(self._inputTable)
	local computedTable: {[any]: ComputedEntry} = self._computedTable

	local didChange = false

	-- clean out main dependency set
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
	table.clear(self.dependencySet)

	-- if the input table is a state object, add it as a dependency
	if inputIsState then
		self._inputTable.dependentSet[self] = true
		self.dependencySet[self._inputTable] = true
	end

	-- stores lists of the keys corresponding to old values
	local keysForOldValues = {}
	-- keys that have already been used
	local alreadyUsedKeys = {}

	-- first go through for differences in keys
	for newInKey, newInValue in pairs(newInputTable) do
		local existingComputed: ComputedEntry = computedTable[newInKey]

		-- if no computed exists for this key, it must be a new key
		-- it may be an old value, we will check later on
		if existingComputed == nil then
			if keysForOldValues[newInValue] == nil then
				keysForOldValues[newInValue] = {}
			end

			table.insert(keysForOldValues[newInValue], newInKey)
		else
			if existingComputed.value ~= newInValue then
				-- update the value to the new value
				-- the change will be captured later by the intermediate value
				existingComputed.value = newInValue

				didChange = true
			end

			alreadyUsedKeys[newInKey] = true
		end
	end

	-- next check all computed entries for matches with old values
	for key, computedEntry in pairs(computedTable) do
		if alreadyUsedKeys[key] then
			continue
		end

		-- if an entry for this value exists, there are keys remaining to be used
		local keyList = keysForOldValues[computedEntry.value]
		if keyList then
			computedEntry.key = table.remove(keyList)

			-- remove it from the dictionary if it is empty
			if keyList[1] == nil then
				keysForOldValues[computedEntry.value] = nil
			end
		else
			-- no keys or values match this computed entry, so run the destructor then remove it
			local oldResult = computedEntry.oldResult
			local destructOK, err = xpcall(self._destructor or cleanup, parseError, oldResult[1], oldResult[2], oldResult[3])
			if not destructOK then
				logErrorNonFatal("forPairsDestructorError", err)
			end

			computedTable[key] = nil
		end

		didChange = true
	end

	-- finally, add the brand new key-value pairs in
	for value, keyList in keysForOldValues do
		for _, key in ipairs(keyList) do
			local entry = {
				key = key,
				value = value,

				newDependencies = {},
				oldDependencies = {},
				oldResult = {},
			}
			-- the intermediates use self to ensure they update after this update function runs
			entry.intermediateKey = Computed(function(use: PubTypes.Use): any
				use(self)
				return entry.key
			end, doNothing)
			entry.intermediateValue = Computed(function(use: PubTypes.Use): any
				use(self)
				return entry.value
			end, doNothing)

			entry.final = Computed(function(use: PubTypes.Use): {any}
				-- we cannot directly pass in use in case it errors
				local function useLogger<T>(target: PubTypes.CanBeState<T>): T
					if isState(target) then
						entry.newDependencies[target] = true
					end

					return peek(target)
				end

				local processOK, newOutKey, newOutValue, newMetaValue = xpcall(
					self._processor, parseError, useLogger, entry.intermediateKey, entry.intermediateValue
				)

				if processOK then
					-- since there was no error, we will use the new dependencies
					entry.oldDependencies, entry.newDependencies = entry.newDependencies, entry.oldDependencies

					-- save the result so we can use it in case of an error
					entry.oldResult[1] = newOutKey
					entry.oldResult[2] = newOutValue
					entry.oldResult[3] = newMetaValue
				else
					logErrorNonFatal("forPairsProcessorError", newOutKey)
				end

				-- now that we determined which dependency set to use, use it now
				for dependency in pairs(entry.oldDependencies) do
					use(dependency)
				end

				-- clear new dependencies for next time
				table.clear(entry.newDependencies)

				return {entry.oldResult[1], entry.oldResult[2], entry.oldResult[3]}
			end, function(old: {any}?): ()
				if old == nil then
					return
				end

				if self._destructor == nil and (needsDestruction(old[1]) or needsDestruction(old[2]) or needsDestruction(old[3])) then
					logWarn("destructorNeededForPairs")
				end

				local destructOK, err = xpcall(self._destructor or cleanup, parseError, old[1], old[2], old[3])
				if not destructOK then
					logErrorNonFatal("forPairsDestructorError", err)
				end
			end)

			computedTable[key] = entry

			didChange = true
		end
	end

	return didChange
end

--[[
	Returns the interior value of this state object.
]]
function class:_peek(): any
	return self._computedTable
end

function class:get()
	logError("stateGetWasRemoved")
end

local function ForPairs<KI, VI, KO, VO, M>(
	inputTable: PubTypes.CanBeState<{ [KI]: VI }>,
	processor: (PubTypes.Use, PubTypes.StateObject<KI>, VI) -> (KO, VO, M?),
	destructor: (KO, VO, M?) -> ()?
): Types.Computed<{[KO]: VO}>

	local inputIsState = isState(inputTable)

	local self = setmetatable({
		type = "State",
		kind = "ForPairs",
		dependencySet = {},
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),

		_processor = processor,
		_destructor = destructor,
		_inputIsState = inputIsState,

		_inputTable = inputTable,
		_computedTable = {},
	}, CLASS_METATABLE)

	self:update()

	-- this Computed combines computedTable's entries into the final table
	return Computed(function(use: PubTypes.Use): {[KO]: VO}
		local computedTable: {[any]: ComputedEntry} = use(self)

		local result = {}
		for _, computedEntry in pairs(computedTable) do
			local entryFinal = use(computedEntry.final)

			local newKey = entryFinal[1]
			local newValue = entryFinal[2]

			-- check for key collision
			if result[newKey] ~= nil then
				-- this is slow to do but it only needs to be done upon error
				for _, checkEntry in pairs(computedTable) do
					if peek(checkEntry.final)[1] == newKey then
						logError(
							"forPairsKeyCollision",
							nil,
							tostring(newKey),
							tostring(checkEntry.key),
							tostring(checkEntry.value),
							tostring(computedEntry.key),
							tostring(computedEntry.value)
						)
					end
				end

				--TODO: Should this warn/error here? It somehow detected a key collision but couldn't find the key that collided with it.
			end

			result[newKey] = newValue
		end

		return result
	end)
end

return ForPairs