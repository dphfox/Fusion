--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	A state object which allows regular Luau code to control its value.

	https://elttob.uk/Fusion/0.3/api-reference/state/types/value/
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

local METATABLE = {}
METATABLE.__index = class

local function Value<T>(
	scope: Types.Scope<unknown>,
	initialValue: T
): Types.Value<T, any>
	if initialValue == nil and (typeof(scope) ~= "table" or (scope[1] == nil and next(scope) ~= nil)) then
		logError("scopeMissing", nil, "Value", "myScope:Value(initialValue)")
	end
	local self: InternalTypes.Value<T, any> = 
		setmetatable(
			{
				dependentSet = {},
				scope = scope,
				validity = "valid",
				_lastChange = os.clock(),
				_value = initialValue
			} :: any, 
			METATABLE
		)
	table.insert(scope, self)
	return self
end

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

function class:_peek(): unknown
	local self = self :: InternalTypes.Value<unknown, unknown>
	return self._value
end

function class:_evaluate(): boolean
	-- The only time a meaningful change occurs is when the value object
	-- manually indicates such a change has occured via `change()`.
	return false
end

return Value