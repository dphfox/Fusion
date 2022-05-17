--!nonstrict

--[[
	Constructs a new ForPairs object which maps pairs of a table using
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

local function forPairsCleanup(keyOut: any, valueOut: any, meta: any?)
	cleanup(keyOut)
	cleanup(valueOut)

	if meta then
		cleanup(meta)
	end
end

--[[
	Returns the current value of this ForPairs object.
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
	- their associated value has changed
	- a dependency used during generation of this value has changed

	It will recalculate those key/value pairs, storing information about any
	dependencies used in the processor callback during value generation, and
	save the new key/value pair to the output array. If it is overwriting an
	older key/value pair, that older pair will be passed to the destructor
	for cleanup.

	Finally, this function will find keys that are no longer present, and remove
	their key/value pairs from the output table and pass them to the destructor.
]]
function class:update(): boolean
	local inputIsState = self._inputIsState
	local oldInputPairs = self._oldInputTable
	local newInputPairs = self._inputTable
	local keyIOMap = self._keyIOMap
	local meta = self._meta

	if inputIsState then
		newInputPairs = newInputPairs:get(false)
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

	-- clean out new output pairs
	self._oldOutputTable, self._outputTable = self._outputTable, self._oldOutputTable

	local oldOutputPairs = self._oldOutputTable
	local newOutputPairs = self._outputTable
	table.clear(newOutputPairs)

	-- STEP 1: find key/value pairs that changed value or were not previously present

	--[[
		- if a key/value input pair doesn't change, it will have the same key/value output pair
		- if only a value changes, (KI) -> (OVI) is replaced by (KI) -> (NVI)
		- if only a key changes, (NKI) -> (VI) is added on to (OKI) -> (VI), and may replace (NKI) -> (OVI)

		- when just a key or a value changes, it is not guaranteed for (KO) -> (VO) to be replaced
			- we intend for keys and values to rely on both key and value, as such we cannot reliably check
				for a previous (KO, VO), given a KI and a VI that *might* have changed
			- as such, we don't need to check for changes in the input table, instead we need to check for
				changes in the output table

		- when both a key and value change, it is still not guaranteed for (KO) -> (VO) to be replaced
			- what if (KIA) -> (VIA) gives us (KO) -> (VO), but (KIB) -> (VIB) also gives us (KO) -> (VO)
				- in this case, (KO) -> (VO) has not been replaced

		maybe?:
			- Let f: (KI, VI) -> (KO, VO)
				- f is not one to one
				- but we want g: (KO) -> (KI, VI) to be a function on any given set of inputs
					- otherwise we can have conflicting inputs
				- we do not care if h: (VO) -> (KI, VI) is a function
					- it is expected for differing (KI, VI) to give the same VO
	]]

	for newInKey, newInValue in pairs(newInputPairs) do
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

		-- if an inputKey's inputValue hasn't changed, neither will its outputKey or outputValue
		local shouldRecalculate = oldInputPairs[newInKey] ~= newInValue

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

			local processOK, newOutKey, newOutValue, newMetaValue = captureDependencies(
				keyData.dependencySet,
				self._processor,
				newInKey,
				newInValue
			)

			if processOK then
				local oldOutValue = oldOutputPairs[newOutKey]

				-- if the output key/value pair has changed
				if oldOutValue ~= newOutValue then
					didChange = true

					-- clean up the old calculated value
					if oldOutValue ~= nil then
						local oldMetaValue = meta[newOutKey]

						local destructOK, err = xpcall(
							self._destructor,
							parseError,
							newOutKey,
							oldOutValue,
							oldMetaValue
						)
						if not destructOK then
							logErrorNonFatal("forPairsDestructorError", err)
						end
					end
				end

				-- if this key was already written to on this run-through, throw a fatal error.
				-- when this occurs, (KIA, VIA) -> (KO, VOA) exists; but (KIB, VIB) -> (KO, VOB) also exists
				-- with no guarantee that VIB == VOB. And because ForPairs is meant to output a key and a value
				-- based on an input key and value, it means that there is a fatal error! Someone might expect
				-- two things to be output with separate values, but because (KO) is being written to twice,
				-- it will only output one thing!
				if newOutputPairs[newOutKey] ~= nil then
					-- figure out which key/value pair previously wrote to this key
					local previousNewKey, previousNewValue
					for inKey, outKey in pairs(keyIOMap) do
						if outKey == newOutKey then
							previousNewValue = newInputPairs[inKey]

							if previousNewValue ~= nil then
								previousNewKey = inKey
								break
							end
						end
					end

					if previousNewKey ~= nil then
						logError(
							"forPairsKeyCollision",
							nil,
							tostring(newOutKey),
							tostring(previousNewKey),
							tostring(previousNewValue),
							tostring(newInKey),
							tostring(newInValue)
						)
					end
				end

				-- make the old input match the new input
				oldInputPairs[newInKey] = newInValue
				-- store the key IO map for key removal detection
				keyIOMap[newInKey] = newOutKey
				-- store the new meta value in the table
				meta[newOutKey] = newMetaValue
				-- store the new output value for next time we run the output comparison
				oldOutputPairs[newOutKey] = newOutValue
				-- store the new output value in the table we give to the user
				newOutputPairs[newOutKey] = newOutValue
			else
				-- restore old dependencies, because the new dependencies may be corrupt
				keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet

				logErrorNonFatal("forPairsProcessorError", newOutKey)
			end
		else
			local newOutKey = keyIOMap[newInKey]

			if newOutputPairs[newOutKey] ~= nil then
				-- figure out which key/value pair previously wrote to this key
				local previousNewKey, previousNewValue
				for inKey, outKey in pairs(keyIOMap) do
					if newOutKey == outKey then
						previousNewValue = newInputPairs[inKey]

						if previousNewValue ~= nil then
							previousNewKey = inKey
							break
						end
					end
				end

				if previousNewKey ~= nil then
					logError(
						"forPairsKeyCollision",
						nil,
						tostring(newOutKey),
						tostring(previousNewKey),
						tostring(previousNewValue),
						tostring(newInKey),
						tostring(newInValue)
					)
				end
			end

			-- store the old output value in the new table we give to the user
			newOutputPairs[newOutKey] = oldOutputPairs[newOutKey]
		end
	end

	-- STEP 2: find keys that were removed

	for key in pairs(oldOutputPairs) do
		-- if this key doesn't have an equivalent in the new output table
		if newOutputPairs[key] == nil then
			-- clean up the old calculated value
			local oldOutValue = oldOutputPairs[key]
			local oldMetaValue = meta[key]
			if oldOutValue ~= nil then
				local destructOK, err = xpcall(self._destructor, parseError, key, oldOutValue, oldMetaValue)
				if not destructOK then
					logErrorNonFatal("forPairsDestructorError", err)
				end
			end

			-- remove meta data
			meta[key] = nil
			-- remove key data
			self._keyData[key] = nil

			-- if we removed a key, then the table/state changed
			didChange = true
		end
	end

	for key in pairs(oldInputPairs) do
		if newInputPairs[key] == nil then
			-- remove key/value pair in old input table
			oldInputPairs[key] = nil

			-- remove old key map
			keyIOMap[key] = nil
		end
	end

	return didChange
end

local function ForPairs<KI, VI, KO, VO, M>(
	inputTable: PubTypes.CanBeState<{ [KI]: VI }>,
	processor: (KI, VI) -> (KO, VO, M?),
	destructor: (KO, VO, M?) -> ()?
): Types.ForPairs<KI, VI, KO, VO, M>
	-- if destructor function is not defined, use the default cleanup function
	if destructor == nil then
		destructor = forPairsCleanup :: (KO, VO, M?) -> ()
	end

	local inputIsState = inputTable.type == "State" and typeof(inputTable.get) == "function"

	local self = setmetatable({
		type = "State",
		kind = "ForPairs",
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
		_oldOutputTable = {},
		_keyIOMap = {},
		_keyData = {},
		_meta = {},
	}, CLASS_METATABLE)

	initDependency(self)
	self:update()

	return self
end

return ForPairs