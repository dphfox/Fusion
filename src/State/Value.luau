--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

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
local change = require(Package.State.change)
-- Utility
local isSimilar = require(Package.Utility.isSimilar)

local class = {}
class.type = "State"
class.kind = "Value"
class.timeliness = "lazy"

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
	local self = self :: InternalTypes.Value<unknown, unknown>
	local oldValue = self._value
	if force or not isSimilar(oldValue, newValue) then
		self._value = newValue
		change(self)
	end
end

--[[
	Returns the interior value of this state object.
]]
function class:_peek(): unknown
	local self = self :: InternalTypes.Value<unknown, unknown>
	return self._value
end

--[[
	Evaluates this graph object.
]]
function class:_evaluate(): boolean
	-- The only time a meaningful change occurs is when the value object
	-- manually indicates such a change has occured via `change()`.
	return false
end

function class:get()
	logError("stateGetWasRemoved")
end

function class:destroy()
	local self = self :: InternalTypes.Value<unknown, unknown>
	if self.scope == nil then
		logError("destroyedTwice", nil, "Value")
	end
	self.scope = nil
end

local function Value<T>(
	scope: Types.Scope<unknown>,
	initialValue: T
): Types.Value<T, any>
	if initialValue == nil and (typeof(scope) ~= "table" or (scope[1] == nil and next(scope) ~= nil)) then
		logError("scopeMissing", nil, "Value", "myScope:Value(initialValue)")
	end

	local self = setmetatable({
		dependentSet = {},
		scope = scope,
		validity = "valid",
		_lastChange = nil,
		_value = initialValue
	}, CLASS_METATABLE)
	local self = (self :: any) :: InternalTypes.Value<T, any>

	table.insert(scope, self)

	return self
end

return Value