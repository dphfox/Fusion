--!nonstrict

--[[
	Constructs a new computed state object which maps pairs of an array using
	a `processor` function.

	Optionally, a `destructor` function can be specified for cleaning up values.
	If omitted, the default cleanup function will be used instead.
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
local dontYield = require(Package.Utility.dontYield)

local class = {}

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}

--[[
	Returns the current value of this ComputedPairs object.
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
	save the new value to the output array. If it is overwriting an older value,
	that older value will be passed to the destructor for cleanup.

	Finally, this function will find keys that are no longer present, and remove
	their values from the output table and pass them to the destructor.

]]
function class:update(): boolean
	local inputIsState = self._inputIsState
	local oldInput = self._oldInputTable
	local newInput = self._inputTable
	local oldOutput = self._oldOutputTable
	local newOutput = self._outputTable

	if inputIsState then
		newInput = newInput:get(false)
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

	-- STEP 1: find keys that changed value or were not previously present

	for key, newInValue in pairs(newInput) do
		-- get or create key data
		local keyData = self._keyData[key]
		if keyData == nil then
			keyData = {
				-- we don't need strong references here - the main set does that
				-- for us, so let's not introduce unnecessary leak opportunities
				dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				oldDependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				dependencyValues = setmetatable({}, WEAK_KEYS_METATABLE)
			}
			self._keyData[key] = keyData
		end

		-- if this value is either new or different, we should recalculate it
		local shouldRecalculate = oldInput[key] ~= newInValue

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

		-- if we should recalculate the value by this point, do that
		if shouldRecalculate then
			keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet
			table.clear(keyData.dependencySet)

			local oldOutValue = oldOutput[key]
			local processOK, newOutValue = dontYield(
				captureDependencies,
				"computedPairsCannotYield",
				keyData.dependencySet, self._processor, key, newInValue
			)

			if processOK then
				-- if the calculated value has changed
				if oldOutValue ~= newOutValue then
					didChange = true

					-- clean up the old calculated value
					if oldOutValue ~= nil then
						local destructOK, err = xpcall(self._destructor, parseError, oldOutValue)
						if not destructOK then
							logErrorNonFatal("pairsDestructorError", err)
						end
					end
				end

				-- make the old input match the new input
				oldInput[key] = newInValue
				-- store the new output value for next time we run the output comparison
				oldOutput[key] = newOutValue
				-- store the new output value in the table we give to the user
				newOutput[key] = newOutValue
			else
				-- restore old dependencies, because the new dependencies may be corrupt
				keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet

				logErrorNonFatal("pairsProcessorError", newOutValue)
			end
		end

		-- save dependency values and add to main dependency set
		for dependency in pairs(keyData.dependencySet) do
			keyData.dependencyValues[dependency] = dependency:get(false)

			self.dependencySet[dependency] = true
			dependency.dependentSet[self] = true
		end
	end

	-- STEP 2: find keys that were removed

	for key in pairs(oldInput) do
		-- if this key doesn't have an equivalent in the new input table
		if newInput[key] == nil then
			-- clean up the old calculated value
			local oldOutValue = oldOutput[key]
			if oldOutValue ~= nil then
				local destructOK, err = xpcall(self._destructor, parseError, oldOutValue)
				if not destructOK then
					logErrorNonFatal("pairsDestructorError", err)
				end
			end

			-- make the old input match the new input
			oldInput[key] = nil
			-- remove the reference to the old output value
			oldOutput[key] = nil
			-- remove the value from the table we give to the user
			newOutput[key] = nil
			-- remove key data
			self._keyData[key] = nil
		end
	end

	return didChange
end

local function ComputedPairs<K, VI, VO>(
	inputTable: PubTypes.CanBeState<{[K]: VI}>,
	processor: (K, VI) -> VO,
	destructor: (VO) -> ()?
): Types.ComputedPairs<K, VI, VO>
	-- if destructor function is not defined, use the default cleanup function
	if destructor == nil then
		destructor = (cleanup) :: (VO) -> ()
	end

	local inputIsState = inputTable.type == "State" and typeof(inputTable.get) == "function"

	local self = setmetatable({
		type = "State",
		kind = "ComputedPairs",
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
		_keyData = {}
	}, CLASS_METATABLE)

	initDependency(self)
	self:update()

	return self
end

return ComputedPairs