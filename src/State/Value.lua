--!nonstrict

--[[
	Constructs and returns objects which can be used to model independent
	reactive state.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Types = require(Package.Types)
-- Logging
local logError = require(Package.Logging.logError)
-- State
local updateAll = require(Package.State.updateAll)
-- Utility
local isSimilar = require(Package.Utility.isSimilar)

local class = {}

local CLASS_METATABLE = {__index = class}

--[[
	Updates the value stored in this State object.

	If `force` is enabled, this will skip equality checks and always update the
	state object and any dependents - use this with care as this can lead to
	unnecessary updates.
]]
function class:set(newValue: any, force: boolean?)
	local oldValue = self._value
	if force or not isSimilar(oldValue, newValue) then
		self._value = newValue
		updateAll(self)
	end
end

--[[
	Returns the interior value of this state object.
]]
function class:_peek(): any
	return self._value
end

function class:get()
	logError("stateGetWasRemoved")
end

function class:destroy()
end

local function Value<T>(
	cleanupTable: {PubTypes.Task},
	initialValue: T
): Types.State<T>
	local self = setmetatable({
		type = "State",
		kind = "Value",
		dependentSet = {},
		_value = initialValue
	}, CLASS_METATABLE)

	table.insert(cleanupTable, self)

	return self
end

return Value