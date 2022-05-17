--!nonstrict

--[[
	Constructs a new ForKeys state object which maps keys of a table using
	a `processor` function.

	Optionally, a `destructor` function can be specified for cleaning up values.
	If omitted, the default cleanup function will be used instead.

    Additionally, a `meta` table/value can optionally be returned to pass data created
    when running the processor to the destructor when the created object is cleaned up.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.State.PubTypes)
local Types = require(Package.State.Types)
local captureDependencies = require(Package.Core.Dependencies.captureDependencies)
local initDependency = require(Package.Core.Dependencies.initDependency)
local useDependency = require(Package.Core.Dependencies.useDependency)
local parseError = require(Package.Core.Logging.parseError)
local logErrorNonFatal = require(Package.Core.Logging.logErrorNonFatal)
local logError = require(Package.Core.Logging.logError)
local cleanup = require(Package.Core.Utility.cleanup)

local class = {}

local CLASS_METATABLE = { __index = class }
local WEAK_KEYS_METATABLE = { __mode = "k" }

local function forKeysCleanup(keyOut: any, meta: any?)
	cleanup(keyOut)

	if meta then
		cleanup(meta)
	end
end

--[[
	Returns the current value of this ForKeys object.
	The object will be registered as a dependency unless `asDependency` is false.
]]
function class:get(asDependency: boolean?): any
	if asDependency ~= false then
		useDependency(self)
	end
	return self._outputTable
end

--[[
	Called when the original table is changed.

	This will firstly find any keys meeting any of the following criteria:

	- they were not previously present
	- a dependency used during generation of this key has changed

	It will recalculate those keys, storing information about any dependencies used
	in the processor callback during value generation, and saving the new key to the
	output array with the same value. If it is overwriting an older value, that older
	value will be passed to the destructor for cleanup.

	Finally, this function will find keys that are no longer present, and remove
	their output key from the output table and pass them to the destructor.
]]
function class:update(): boolean
	local inputIsState = self._inputIsState
	local oldInputKeys = self._oldInputTable
	local newInputKeys = self._inputTable
	local keyOIMap = self._keyOIMap
	local outputKeys = self._outputTable
	local meta = self._meta

	if inputIsState then
		newInputKeys = newInputKeys:get(false)
	end

	local didChange = false

	-- clean out main dependency set
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
	self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet
	table.clear(self.dependencySet)

	-- if the input table is a state object, add as dependency
	if inputIsState then
		self._inputTable.dependentSet[self] = true
		self.dependencySet[self._inputTable] = true
	end

	-- STEP 1: find keys that were not previously present
	for newInKey, _value in pairs(newInputKeys) do
		-- get or create key data
		local keyData = self._keyData[newInKey]
		if keyData == nil then
			keyData = {
				-- we don't need strong references here - the main set does that
				-- for us, so let's not introduce unnecessary leak opportunities
				dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				oldDependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				dependencyValues = setmetatable({}, WEAK_KEYS_METATABLE),
			}
			self._keyData[newInKey] = keyData
		end

		-- if an input key's previous value is non-nil, then there's no need to recalculate it
		-- this also allows it to have a non-truthy value, which is important since we don't care
		-- about the value; if we have dependencies then we also need to check if they've changed,
		-- since if they have then the key has "changed".
		local shouldRecalculate = oldInputKeys[newInKey] == nil

		if not shouldRecalculate then
			-- check if dependencies have changed
			for dependency, oldValue in pairs(keyData.dependencyValues) do
				-- if the dependency changed value, then this needs recalculating
				if oldValue ~= dependency:get(false) then
					shouldRecalculate = true
					break
				end
			end
		end

		-- if we should recalculate the output by this point, do that
		if shouldRecalculate then
			keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet
			table.clear(keyData.dependencySet)

			local processOK, newOutKey, newMetaValue = captureDependencies(
				keyData.dependencySet,
				self._processor,
				newInKey
			)

			if processOK then
				local oldInKey = keyOIMap[newOutKey]

				-- if there are colliding output keys, throw an error
				if oldInKey ~= newInKey and newInputKeys[oldInKey] ~= nil then
					logError("forKeysKeyCollision", nil, tostring(newOutKey), tostring(oldInKey), tostring(newOutKey))
				end

				-- make the old input match the new input value
				oldInputKeys[newInKey] = _value
				-- store the new meta value in the table
				meta[newOutKey] = newMetaValue
				-- store the new output key for next time we run the output comparison
				keyOIMap[newOutKey] = newInKey
				-- store the new output key in the table with its original value, which we give to the user
				outputKeys[newOutKey] = _value

				-- if we had to recalculate the output, then we did change
				didChange = true
			else
				-- restore old dependencies, because the new dependencies may be corrupt
				keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet

				logErrorNonFatal("forKeysProcessorError", newOutKey)
			end
		end
	end

	-- STEP 2: find keys that were removed

	for outputKey, inputKey in pairs(keyOIMap) do
		-- if the output key doesn't have an equivalent input key in the new input table
		if newInputKeys[inputKey] == nil then
			-- clean up the old calculated value
			local oldMetaValue = meta[outputKey]

			local destructOK, err = xpcall(self._destructor, parseError, outputKey, oldMetaValue)
			if not destructOK then
				logErrorNonFatal("forKeysDestructorError", err)
			end

			-- remove input key
			oldInputKeys[inputKey] = nil
			-- remove meta data
			meta[outputKey] = nil
			-- remove key OI data
			keyOIMap[outputKey] = nil
			-- remove output key
			outputKeys[outputKey] = nil
			-- remove key data
			self._keyData[inputKey] = nil

			-- if we removed a key, then the table/state changed
			didChange = true
		end
	end

	return didChange
end

local function ForKeys<KI, KO, M>(
	inputTable: PubTypes.CanBeState<{ [KI]: any }>,
	processor: (KI) -> (KO, M?),
	destructor: (KO, M?) -> ()?
): Types.ForKeys<KI, KO, M>
	-- if destructor function is not defined, use the default cleanup function
	if destructor == nil then
		destructor = forKeysCleanup :: (KO, M?) -> ()
	end

	local inputIsState = inputTable.type == "State" and typeof(inputTable.get) == "function"

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
		_keyData = {},
		_meta = {},
	}, CLASS_METATABLE)

	initDependency(self)
	self:update()

	return self
end

return ForKeys