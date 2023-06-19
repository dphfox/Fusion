--!nonstrict

--[[
	Constructs a new ForKeys state object which maps keys of an array using
	a `processor` function.

	Optionally, a `destructor` function can be specified for cleaning up
	calculated keys. If omitted, the default cleanup function will be used instead.

	Optionally, a `meta` value can be returned in the processor function as the
	second value to pass data from the processor to the destructor.
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
local needsDestruction = require(Package.Utility.needsDestruction)
-- State
local peek = require(Package.State.peek)
local makeUseCallback = require(Package.State.makeUseCallback)
local isState = require(Package.State.isState)

local class = {}

local CLASS_METATABLE = { __index = class }
local WEAK_KEYS_METATABLE = { __mode = "k" }


--[[
	Called when the original table is changed.

	This will firstly find any keys meeting any of the following criteria:

	- they were not previously present
	- a dependency used during generation of this value has changed

	It will recalculate those key pairs, storing information about any
	dependencies used in the processor callback during output key generation,
	and save the new key to the output array with the same value. If it is
	overwriting an older value, that older value will be passed to the
	destructor for cleanup.

	Finally, this function will find keys that are no longer present, and remove
	their output keys from the output table and pass them to the destructor.
]]

function class:update(): boolean
	local inputIsState = self._inputIsState
	local newInputTable = peek(self._inputTable)
	local oldInputTable = self._oldInputTable
	local outputTable = self._outputTable

	local keyOIMap = self._keyOIMap
	local keyIOMap = self._keyIOMap
	local meta = self._meta

	local didChange = false


	-- clean out main dependency set
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end

	self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet
	table.clear(self.dependencySet)

	-- if the input table is a state object, add it as a dependency
	if inputIsState then
		self._inputTable.dependentSet[self] = true
		self.dependencySet[self._inputTable] = true
	end


	-- STEP 1: find keys that changed or were not previously present
	for newInKey, value in pairs(newInputTable) do
		-- get or create key data
		local keyData = self._keyData[newInKey]

		if keyData == nil then
			keyData = {
				dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				oldDependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				dependencyValues = setmetatable({}, WEAK_KEYS_METATABLE),
			}
			self._keyData[newInKey] = keyData
		end

		-- check if the key is new
		local shouldRecalculate = oldInputTable[newInKey] == nil

		-- check if the key's dependencies have changed
		if shouldRecalculate == false then
			for dependency, oldValue in pairs(keyData.dependencyValues) do
				if oldValue ~= peek(dependency) then
					shouldRecalculate = true
					break
				end
			end
		end


		-- recalculate the output key if necessary
		if shouldRecalculate then
			keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet
			table.clear(keyData.dependencySet)

			local use = makeUseCallback(keyData.dependencySet)
			local processOK, newOutKey, newMetaValue = xpcall(self._processor, parseError, use, newInKey)

			if processOK then
				if self._destructor == nil and (needsDestruction(newOutKey) or needsDestruction(newMetaValue)) then
					logWarn("destructorNeededForKeys")
				end

				local oldInKey = keyOIMap[newOutKey]
				local oldOutKey = keyIOMap[newInKey]

				-- check for key collision
				if oldInKey ~= newInKey and newInputTable[oldInKey] ~= nil then
					logError("forKeysKeyCollision", nil, tostring(newOutKey), tostring(oldInKey), tostring(newOutKey))
				end

				-- check for a changed output key
				if oldOutKey ~= newOutKey and keyOIMap[oldOutKey] == newInKey then
					-- clean up the old calculated value
					local oldMetaValue = meta[oldOutKey]

					local destructOK, err = xpcall(self._destructor or cleanup, parseError, oldOutKey, oldMetaValue)
					if not destructOK then
						logErrorNonFatal("forKeysDestructorError", err)
					end

					keyOIMap[oldOutKey] = nil
					outputTable[oldOutKey] = nil
					meta[oldOutKey] = nil
				end

				-- update the stored data for this key
				oldInputTable[newInKey] = value
				meta[newOutKey] = newMetaValue
				keyOIMap[newOutKey] = newInKey
				keyIOMap[newInKey] = newOutKey
				outputTable[newOutKey] = value

				-- if we had to recalculate the output, then we did change
				didChange = true
			else
				-- restore old dependencies, because the new dependencies may be corrupt
				keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet

				logErrorNonFatal("forKeysProcessorError", newOutKey)
			end
		end


		-- save dependency values and add to main dependency set
		for dependency in pairs(keyData.dependencySet) do
			keyData.dependencyValues[dependency] = peek(dependency)

			self.dependencySet[dependency] = true
			dependency.dependentSet[self] = true
		end
	end


	-- STEP 2: find keys that were removed
	for outputKey, inputKey in pairs(keyOIMap) do
		if newInputTable[inputKey] == nil then
			-- clean up the old calculated value
			local oldMetaValue = meta[outputKey]

			local destructOK, err = xpcall(self._destructor or cleanup, parseError, outputKey, oldMetaValue)
			if not destructOK then
				logErrorNonFatal("forKeysDestructorError", err)
			end

			-- remove data
			oldInputTable[inputKey] = nil
			meta[outputKey] = nil
			keyOIMap[outputKey] = nil
			keyIOMap[inputKey] = nil
			outputTable[outputKey] = nil
			self._keyData[inputKey] = nil

			-- if we removed a key, then the table/state changed
			didChange = true
		end
	end

	return didChange
end

--[[
	Returns the interior value of this state object.
]]
function class:_peek(): any
	return self._outputTable
end

function class:get()
	logError("stateGetWasRemoved")
end

local function ForKeys<KI, KO, M>(
	inputTable: PubTypes.CanBeState<{ [KI]: any }>,
	processor: (KI) -> (KO, M?),
	destructor: (KO, M?) -> ()?
): Types.ForKeys<KI, KO, M>

	local inputIsState = isState(inputTable)

	local self = setmetatable({
		type = "State",
		kind = "ForKeys",
		dependencySet = {},
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_oldDependencySet = {},

		_processor = processor,
		_destructor = destructor,
		_inputIsState = inputIsState,

		_inputTable = inputTable,
		_oldInputTable = {},
		_outputTable = {},
		_keyOIMap = {},
		_keyIOMap = {},
		_keyData = {},
		_meta = {},
	}, CLASS_METATABLE)

	self:update()

	return self
end

return ForKeys