--!nonstrict

--[[
	The private generic implementation for all public `For` objects.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Types = require(Package.Types)
-- Logging
local logError = require(Package.Logging.logError)
-- State
local peek = require(Package.State.peek)
local isState = require(Package.State.isState)

local class = {}

local CLASS_METATABLE = { __index = class }
local WEAK_KEYS_METATABLE = { __mode = "k" }


--[[
	Called when the original table is changed.
]]

function class:update(): boolean
	local inputIsState = self._inputIsState
	local newInputTable = peek(self._inputTable)
	local existingProcessors = error("TODO")

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

	local remainingPairs = {}
	local numPairs = 0
	for key, value in newInputTable do
		numPairs += 1
		if remainingPairs[key] == nil then
			remainingPairs[key] = {[value] = true}
		else
			remainingPairs[key][value] = true
		end
	end

	local newProcessors = {}
	-- First, try and reuse processors who match both the key and value of a
	-- remaining pair. This can be done with no recomputation.
	for tryReuseProcessor in existingProcessors do
		if numPairs <= 0 then
			break
		end
		local key = peek(tryReuseProcessor.key)
		local value = peek(tryReuseProcessor.value)
		if remainingPairs[key] ~= nil and remainingPairs[key][value] ~= nil then
			remainingPairs[key][value] = nil
			numPairs -= 1
			error("TODO: bring forward key from old table")
			newProcessors[tryReuseProcessor] = true
		end
	end
	-- Next, try and reuse processors who match the key of a remaining pair.
	-- The value will change but the key will stay stable.
	for tryReuseProcessor in existingProcessors do
		if numPairs <= 0 then
			break
		elseif newProcessors[tryReuseProcessor] == nil then
			local key = peek(tryReuseProcessor.key)
			if remainingPairs[key] ~= nil then
				local value = next(remainingPairs[key])
				if value ~= nil then
					remainingPairs[key][value] = nil
					numPairs -= 1
					tryReuseProcessor.value:set(value)
					error("TODO: bring forward key from old table")
					newProcessors[tryReuseProcessor] = true
				end
			end
		end
	end
	-- Next, try and reuse processors who match the value of a remaining pair.
	-- The key will change but the value will stay stable.
	for tryReuseProcessor in existingProcessors do
		error("TODO")
	end
	-- Finally, try and reuse any remaining processors, even if they do not
	-- match a pair. Both key and value will be changed.
	for tryReuseProcessor in existingProcessors do
		error("TODO")
	end
	-- By this point, we can be in one of three cases:
	-- 1) some existing processors are left over; no remaining pairs (shrunk)
	-- 2) no existing processors are left over; no remaining pairs (same size)
	-- 3) no existing processors are left over; some remaining pairs (grew)
	-- So, existing processors should be destroyed, and remaining pairs should
	-- be created. This accomodates for table growth and shrinking.


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
		_oldDependencySet = {},

		_processor = processor,
		_inputIsState = isState(inputTable),

		_inputTable = inputTable,
		_oldInputTable = {},
		_outputTable = {}
	}, CLASS_METATABLE)

	self:update()
	table.insert(cleanupTable, self)

	return self
end

return For