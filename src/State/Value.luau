--!strict
--!nolint LocalShadow

--[[
	Constructs and returns objects which can be used to model independent
	reactive state.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
-- Logging
local logError = require(Package.Logging.logError)
-- State
local updateAll = require(Package.State.updateAll)
-- Utility
local isSimilar = require(Package.Utility.isSimilar)

local class = {}
class.type = "State"
class.kind = "Value"

local CLASS_METATABLE = {__index = class}

--[[
	Updates the value stored in this State object.

	If `force` is enabled, this will skip equality checks and always update the
	state object and any dependents - use this with care as this can lead to
	unnecessary updates.
]]
function class:set(
	newValue: unknown,
	force: boolean?
)
	local self = self :: InternalTypes.Value<unknown>
	local oldValue = self._value
	if force or not isSimilar(oldValue, newValue) then
		self._value = newValue
		updateAll(self)
	end
end

--[[
	Returns the interior value of this state object.
]]
function class:_peek(): unknown
	local self = self :: InternalTypes.Value<unknown>
	return self._value
end

function class:get()
	logError("stateGetWasRemoved")
end

function class:destroy()
	local self = self :: InternalTypes.Value<unknown>
	if self.scope == nil then
		logError("destroyedTwice", nil, "Value")
	end
	self.scope = nil
end

local function Value<T>(
	scope: Types.Scope<unknown>,
	initialValue: T
): Types.Value<T>
	if initialValue == nil and (typeof(scope) ~= "table" or (scope[1] == nil and next(scope) ~= nil)) then
		logError("scopeMissing", nil, "Value", "myScope:Value(initialValue)")
	end

	local self = setmetatable({
		scope = scope,
		dependentSet = {},
		_value = initialValue
	}, CLASS_METATABLE)
	local self = (self :: any) :: InternalTypes.Value<T>

	table.insert(scope, self)

	return self
end

return Value