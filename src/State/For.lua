--!nonstrict

--[[
	The private generic implementation for all public `For` objects.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Types = require(Package.Types)
-- Logging
local logError = require(Package.Logging.logError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local parseError = require(Package.Logging.parseError)
-- State
local peek = require(Package.State.peek)
local isState = require(Package.State.isState)
local Value = require(Package.State.Value)
-- Memory
local doCleanup = require(Package.Memory.doCleanup)

local class = {}

local CLASS_METATABLE = { __index = class }
local WEAK_KEYS_METATABLE = { __mode = "k" }

type Processor = {
	inputKey: PubTypes.Value<any>,
	inputValue: PubTypes.Value<any>,
	outputKey: PubTypes.StateObject<any>,
	outputValue: PubTypes.StateObject<any>,
	cleanupTask: any
}

--[[
	Called when the original table is changed.
]]

function class:update(): boolean
	local newInputTable = peek(self._inputTable)
	local existingProcessors = self._existingProcessors :: {[Processor]: true}

	local remainingPairs = self._remainingPairs
	table.clear(remainingPairs)
	for key, value in newInputTable do
		if remainingPairs[key] == nil then
			remainingPairs[key] = {[value] = true}
		else
			remainingPairs[key][value] = true
		end
	end

	local newProcessors: {[Processor]: true} = self._newProcessors
	-- First, try and reuse processors who match both the key and value of a
	-- remaining pair. This can be done with no recomputation.
	for tryReuseProcessor in existingProcessors do
		local key = peek(tryReuseProcessor.inputKey)
		local value = peek(tryReuseProcessor.inputValue)
		local remainingValues = remainingPairs[key]
		if remainingValues ~= nil and remainingValues[value] ~= nil then
			remainingValues[value] = nil
			error("TODO: bring forward key from old table")
			newProcessors[tryReuseProcessor] = true
			existingProcessors[tryReuseProcessor] = nil
		end
	end
	-- Next, try and reuse processors who match the key of a remaining pair.
	-- The value will change but the key will stay stable.
	for tryReuseProcessor in existingProcessors do
		local key = peek(tryReuseProcessor.inputKey)
		local remainingValues = remainingPairs[key]
		if remainingValues ~= nil then
			local value = next(remainingValues)
			if value ~= nil then
				remainingValues[value] = nil
				tryReuseProcessor.inputValue:set(value)
				error("TODO: bring forward key from old table")
				newProcessors[tryReuseProcessor] = true
				existingProcessors[tryReuseProcessor] = nil
			end
		end
	end
	-- Next, try and reuse processors who match the value of a remaining pair.
	-- The key will change but the value will stay stable.
	for tryReuseProcessor in existingProcessors do
		local value = peek(tryReuseProcessor.inputValue)
		for key, remainingValues in remainingPairs do
			if remainingValues[value] ~= nil then
				remainingValues[value] = nil
				tryReuseProcessor.inputKey:set(key)
				error("TODO: bring forward key from old table")
				newProcessors[tryReuseProcessor] = true
				existingProcessors[tryReuseProcessor] = nil
			end
		end
	end
	-- Finally, try and reuse any remaining processors, even if they do not
	-- match a pair. Both key and value will be changed.
	for tryReuseProcessor in existingProcessors do
		for _, remainingValues in remainingPairs do
			local value = next(remainingValues)
			if value ~= nil then
				remainingValues[value] = nil
				tryReuseProcessor.inputValue:set(value)
				error("TODO: bring forward key from old table")
				newProcessors[tryReuseProcessor] = true
				existingProcessors[tryReuseProcessor] = nil
			end
		end
	end
	-- By this point, we can be in one of three cases:
	-- 1) some existing processors are left over; no remaining pairs (shrunk)
	-- 2) no existing processors are left over; no remaining pairs (same size)
	-- 3) no existing processors are left over; some remaining pairs (grew)
	-- So, existing processors should be destroyed, and remaining pairs should
	-- be created. This accomodates for table growth and shrinking.
	for unusedProcessor in existingProcessors do
		doCleanup(unusedProcessor.cleanupTask)
	end
	table.clear(existingProcessors)

	for key, remainingValues in remainingPairs do
		for value in remainingValues do
			local scope = {}
			local inputKey = Value(scope, key)
			local inputValue = Value(scope, value)
			local processOK, outputKey, outputValue = xpcall(self._processor, parseError, inputKey, inputValue)
			if processOK then
				local processor = {
					inputKey = inputKey,
					inputValue = inputValue,
					outputKey = outputKey,
					outputValue = outputValue
				}
				newProcessors[processor] = true
			else
				logErrorNonFatal("forProcessorError", outputKey)
			end
			
		end
	end

	self._existingProcessors = newProcessors
	self._newProcessors = existingProcessors

	error("TODO: reconstruct table")

	return error("TODO")
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

function class:destroy()
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
	
	error("TODO")
end

local function For<KI, VI, KO, VO>(
	cleanupTable: {PubTypes.Task},
	inputTable: PubTypes.CanBeState<{ [KI]: VI }>,
	processor: (
		PubTypes.StateObject<KI>,
		PubTypes.StateObject<VI>
	) -> (PubTypes.StateObject<KO>, PubTypes.StateObject<VO>)
): Types.For<KI, KO, VI, VO>

	local self = setmetatable({
		type = "State",
		kind = "For",
		dependencySet = {},
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_processor = processor,
		_inputTable = inputTable,
		_outputTable = {},
		_existingProcessors = {},
		_newProcessors = {},
		_remainingPairs = {}
	}, CLASS_METATABLE)

	self:update()
	if isState(self._inputTable) then
		self._inputTable.dependentSet[self] = true
		self.dependencySet[self._inputTable] = true
	end
	
	table.insert(cleanupTable, self)

	return self
end

return For