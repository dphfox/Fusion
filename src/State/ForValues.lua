--!nonstrict

--[[
	Constructs a new ForValues state object which maps values of a table using
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
local cleanup = require(Package.Core.Utility.cleanup)

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
	local inputValues = self._inputTable
	local newValueCache = self._oldValueCache -- _oldValueCache and _valueCache get swapped and cleared below
	local oldValueCache = self._valueCache
	local dependenciesCaptured = {} -- we use this to cache dependency checks/captures
	local outputValues = {}
	local meta = self._meta

	if inputIsState then
		inputValues = inputValues:get(false)
	end

	local didChange = false

	-- clean out main dependency set
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
	self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet
	table.clear(self.dependencySet)

	-- swap caches and clear out the old value cache
	self._oldValueCache, self._valueCache = oldValueCache, newValueCache
	table.clear(newValueCache)

	-- if the input table is a state object, add as dependency
	if inputIsState then
		self._inputTable.dependentSet[self] = true
		self.dependencySet[self._inputTable] = true
	end

	-- STEP 1: find values that changed or were not previously present
	for _key, inValue in pairs(inputValues) do
		local cachedValue = oldValueCache[inValue]
		local newCachedValue = newValueCache[inValue]
		local shouldRecalculate = cachedValue == nil

		-- get value data
		local valueData = self._valueData[inValue]
		if valueData == nil then
			valueData = {
				-- we don't need strong references here - the main set does that
				-- for us, so let's not introduce unnecessary leak opportunities
				dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				oldDependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				dependencyValues = setmetatable({}, WEAK_KEYS_METATABLE),
			}
			self._valueData[inValue] = valueData
		end

		-- if we already cached a new constant (non-table) value on this run-through,
		-- then we can just re-use that as the cached value
		if newCachedValue ~= nil and type(newCachedValue) ~= "table" then
			cachedValue = newCachedValue
			shouldRecalculate = false

			-- check inputValue dependencies if we have a cached value
			-- if we don't have a cached value, then there's no point in checking dependencies
			-- we also verify that we haven't already captured the dependencies for this inValue
			-- since if we have, then we don't need to recalculate and can skip this step
		elseif not shouldRecalculate and dependenciesCaptured[inValue] == nil then
			-- check if dependencies have changed
			for dependency, oldValue in pairs(valueData.dependencyValues) do
				-- if the dependency changed value, then this needs recalculating
				if oldValue ~= dependency:get(false) then
					shouldRecalculate = true
					break
				end
			end

			--[[
                If the dependencies have changed then:
                    1: clean up cached value(s), because they are no longer any good
                    2: Swap the old/new dependencies

                This also makes the cached value 'nil', which fits
            ]]
			if shouldRecalculate then
				-- step 1: clean up cached value(s), because they are no longer any good
				-- this also tells future runs to calculate a fresh output value
				cachedValue = if type(cachedValue) == "table" then cachedValue else {cachedValue}

				for _, outputValue in ipairs(cachedValue) do
					-- clean up the old calculated value
					local oldMetaValue = meta[outputValue]
					local destructOK, err = xpcall(self._destructor, parseError, outputValue, oldMetaValue)
					if not destructOK then
						logErrorNonFatal("forValuesDestructorError", err)
					end

					-- remove stored value data
					meta[outputValue] = nil
				end

				-- step 2: swap the old/new dependencies; clean out the new dependency set so we get a fresh start
				valueData.oldDependencySet, valueData.dependencySet =
					valueData.dependencySet, valueData.oldDependencySet
				table.clear(valueData.dependencySet)

				-- step 3: remove stored cached value
				oldValueCache[inValue] = nil
				cachedValue = nil
			else
				-- inform future runs that we already checked this inValue's dependencies,
				-- and that we don't need to re-capture dependencies
				dependenciesCaptured[inValue] = true
			end
		end

		-- if we still don't need to recalculate, then we can re-use a cached value
		-- if there are no cached values, then set recalculate to true and
		-- calculate a new value
		if not shouldRecalculate then
			-- if we're using a table, then try to pull a value from the cache
			if type(cachedValue) == "table" then
				local cachedValues = cachedValue
				local cachedValuesSize = #cachedValues

				if cachedValuesSize > 0 then
					cachedValue = cachedValues[cachedValuesSize]
					table.remove(cachedValues, cachedValuesSize)
				else
					cachedValue = nil
					shouldRecalculate = true
				end
			end
		end

		-- if we should recalculate the output by this point, do that
		if shouldRecalculate then
			local processOK, newOutValue, newMetaValue

			-- if we already captured the dependencies for this inValue, we don't need to do it again
			if dependenciesCaptured[inValue] then
				processOK, newOutValue, newMetaValue = pcall(self._processor, inValue)

				-- otherwise, we need to capture the dependencies
			else
				processOK, newOutValue, newMetaValue = captureDependencies(
					valueData.dependencySet,
					self._processor,
					inValue
				)
			end

			if processOK then
				-- prepare the value to be cached
				cachedValue = newOutValue
				-- store meta value, since we don't touch that when reusing values
				meta[newOutValue] = newMetaValue
				-- inform future runs that we already captured the dependencies
				dependenciesCaptured[inValue] = true

				didChange = true
			else
				logErrorNonFatal("forValuesProcessorError", newOutValue)
			end
		end

		-- if we successfully created a new value or found a value to reuse,
		-- cache it and update the stored data
		if cachedValue ~= nil then
			-- we store tables and objects in an array of cached objects, since they need to be unique
			if type(cachedValue) == "userdata" or type(cachedValue) == "table" then
				local cachedValues = newValueCache[inValue]
				if not cachedValues then
					cachedValues = {}
					newValueCache[inValue] = cachedValues
				end

				table.insert(cachedValues, cachedValue)
			else
				newValueCache[inValue] = cachedValue
			end

			-- store the value in the output with the same key
			outputValues[_key] = cachedValue
		end
	end

	-- STEP 2: find values that were removed
	-- for tables of data, we just need to check if it's still in the cache
	for oldInValue, oldCachedValue in pairs(oldValueCache) do
		if type(oldCachedValue) == "table" then
			-- clean up any remaining cached values
			for _, cachedValue in ipairs(oldCachedValue) do
				local oldMetaValue = meta[cachedValue]
				local destructOK, err = xpcall(self._destructor, parseError, cachedValue, oldMetaValue)
				if not destructOK then
					logErrorNonFatal("forValuesDestructorError", err)
				end

				-- remove stored value data
				meta[cachedValue] = nil

				-- if we removed a value, then we did change
				didChange = true
			end
		elseif newValueCache[oldInValue] ~= oldCachedValue then
			-- clean up the old calculated value
			local oldMetaValue = meta[oldCachedValue]
			local destructOK, err = xpcall(self._destructor, parseError, oldCachedValue, oldMetaValue)
			if not destructOK then
				logErrorNonFatal("forValuesDestructorError", err)
			end

			-- remove stored value data
			meta[oldCachedValue] = nil

			-- if we removed a value, then we did change
			didChange = true
		end
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
		_valueData = {},
		_meta = {},
	}, CLASS_METATABLE)

	initDependency(self)
	self:update()

	return self
end

return ForValues