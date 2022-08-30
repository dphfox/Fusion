--!nonstrict

--[[
	Constructs a new ForValues object which maps values of a table using
	a `processor` function.

	Optionally, a `destructor` function can be specified for cleaning up values.
	If omitted, the default cleanup function will be used instead.

	Additionally, a `meta` table/value can optionally be returned to pass data created
	when running the processor to the destructor when the created object is cleaned up.
]]
local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Types = require(Package.Types)
local captureDependencies = require(Package.Dependencies.captureDependencies)
local initDependency = require(Package.Dependencies.initDependency)
local useDependency = require(Package.Dependencies.useDependency)
local parseError = require(Package.Logging.parseError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local cleanup = require(Package.Utility.cleanup)

local class = {}

local CLASS_METATABLE = { __index = class }
local WEAK_KEYS_METATABLE = { __mode = "k" }

local function forValuesCleanup(keyOut: any, meta: any?)
	cleanup(keyOut)

	if meta then
		cleanup(meta)
	end
end

--[[
	Returns the current value of this ForValues object.
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

	This will firstly find any values meeting any of the following criteria:

	- they were not previously present
	- a dependency used during generation of this value has changed

	It will recalculate those values, storing information about any dependencies
	used in the processor callback during value generation, and save the new value
	to the output array with the same key. If it is overwriting an older value,
	that older value will be passed to the destructor for cleanup.

	Finally, this function will find values that are no longer present, and remove
	their values from the output table and pass them to the destructor. You can re-use
	the same value multiple times and this will function will update them as little as
	possible; reusing the same values where possible.
]]
function class:update(): boolean
	local inputIsState = self._inputIsState
	local inputTable = if inputIsState then self._inputTable:get(false) else self._inputTable
	local outputValues = {}

	local didChange = false

	-- clean out value cache
	self._oldValueCache, self._valueCache = self._valueCache, self._oldValueCache
	local newValueCache = self._valueCache
	local oldValueCache = self._oldValueCache
	table.clear(newValueCache)

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


	-- STEP 1: find values that changed or were not previously present
	for inKey, inValue in pairs(inputTable) do
		-- check if the value is new or changed
		local oldCachedValues = oldValueCache[inValue]
		local shouldRecalculate = oldCachedValues == nil

		-- get a cached value and its dependency/meta data if available
		local value, valueData, meta

		if type(oldCachedValues) == "table" and #oldCachedValues > 0 then
			local valueInfo = table.remove(oldCachedValues, #oldCachedValues)
			value = valueInfo.value
			valueData = valueInfo.valueData
			meta = valueInfo.meta

			if #oldCachedValues <= 0 then
				oldValueCache[inValue] = nil
			end
		elseif oldCachedValues ~= nil then
			oldValueCache[inValue] = nil
			shouldRecalculate = true
		end

		if valueData == nil then
			valueData = {
				dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				oldDependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				dependencyValues = setmetatable({}, WEAK_KEYS_METATABLE),
			}
		end

		-- check if the value's dependencies have changed
		if shouldRecalculate == false then
			for dependency, oldValue in pairs(valueData.dependencyValues) do
				if oldValue ~= dependency:get(false) then
					shouldRecalculate = true
					break
				end
			end
		end

		-- recalculate the output value if necessary
		if shouldRecalculate then
			valueData.oldDependencySet, valueData.dependencySet = valueData.dependencySet, valueData.oldDependencySet
			table.clear(valueData.dependencySet)

			local processOK, newOutValue, newMetaValue = captureDependencies(
				valueData.dependencySet,
				self._processor,
				inValue
			)

			if processOK then
				-- pass the old value to the destructor if it exists
				if value ~= nil then
					local destructOK, err = xpcall(self._destructor, parseError, value, meta)
					if not destructOK then
						logErrorNonFatal("forValuesDestructorError", err)
					end
				end

				-- store the new value and meta data
				value = newOutValue
				meta = newMetaValue
				didChange = true
			else
				-- restore old dependencies, because the new dependencies may be corrupt
				valueData.oldDependencySet, valueData.dependencySet = valueData.dependencySet, valueData.oldDependencySet

				logErrorNonFatal("forValuesProcessorError", newOutValue)
			end
		end


		-- store the value and its dependency/meta data
		local newCachedValues = newValueCache[inValue]
		if newCachedValues == nil then
			newCachedValues = {}
			newValueCache[inValue] = newCachedValues
		end

		table.insert(newCachedValues, {
			value = value,
			valueData = valueData,
			meta = meta,
		})

		outputValues[inKey] = value


		-- save dependency values and add to main dependency set
		for dependency in pairs(valueData.dependencySet) do
			valueData.dependencyValues[dependency] = dependency:get(false)

			self.dependencySet[dependency] = true
			dependency.dependentSet[self] = true
		end
	end


	-- STEP 2: find values that were removed
	-- for tables of data, we just need to check if it's still in the cache
	for _oldInValue, oldCachedValueInfo in pairs(oldValueCache) do
		for _, valueInfo in ipairs(oldCachedValueInfo) do
			local oldValue = valueInfo.value
			local oldMetaValue = valueInfo.meta

			local destructOK, err = xpcall(self._destructor, parseError, oldValue, oldMetaValue)
			if not destructOK then
				logErrorNonFatal("forValuesDestructorError", err)
			end

			didChange = true
		end

		table.clear(oldCachedValueInfo)
	end

	self._outputTable = outputValues

	return didChange
end

local function ForValues<VI, VO, M>(
	inputTable: PubTypes.CanBeState<{ [any]: VI }>,
	processor: (VI) -> (VO, M?),
	destructor: (VO, M?) -> ()?
): Types.ForValues<VI, VO, M>
	-- if destructor function is not defined, use the default cleanup function
	if destructor == nil then
		destructor = forValuesCleanup :: (VO, M?) -> ()
	end

	local inputIsState = inputTable.type == "State" and typeof(inputTable.get) == "function"

	local self = setmetatable({
		type = "State",
		kind = "ForValues",
		dependencySet = {},
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_oldDependencySet = {},

		_processor = processor,
		_destructor = destructor,
		_inputIsState = inputIsState,

		_inputTable = inputTable,
		_outputTable = {},
		_valueCache = {},
		_oldValueCache = {},
	}, CLASS_METATABLE)

	initDependency(self)
	self:update()

	return self
end

return ForValues
