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
-- Logging
local logError = require(Package.Logging.logError)
-- State
local change = require(Package.State.change)
-- Utility
local isSimilar = require(Package.Utility.isSimilar)
local never = require(Package.Utility.never)

type Self<T, S> = Types.Value<T, S> & {
	_value: S
}

local class = {}
class.type = "State"
class.kind = "Value"
class.timeliness = "lazy"

local METATABLE = {}
METATABLE.__index = class

local function Value<T>(
	scope: Types.Scope<unknown>,
	initialValue: T
): Self<T, any>
	if initialValue == nil and (typeof(scope) ~= "table" or (scope[1] == nil and next(scope) ~= nil)) then
		logError("scopeMissing", nil, "Value", "myScope:Value(initialValue)")
	end
	local self = 
		setmetatable(
			{
				dependentSet = {},
				scope = scope,
				validity = "valid",
				_lastChange = os.clock(),
				_value = initialValue
			}, 
			METATABLE
		)
	table.insert(scope, self)
	return self :: any
end

function class.destroy<T, S>(
	self: Self<T, S>
): ()
	if self.scope == nil then
		logError("destroyedTwice", nil, "Value")
	end
	self.scope = nil
end

function class:get<T, S>(
	_self: Self<T, S>
): never
	logError("stateGetWasRemoved")
	return never()
end

function class.set<T, S>(
	self: Self<T, S>,
	newValue: S
): ()
	local oldValue = self._value
	if not isSimilar(oldValue, newValue) then
		self._value = newValue
		change(self)
	end
end

function class._evaluate<T, S>(
	_self: Self<T, S>
): boolean
	-- The only time a meaningful change occurs is when the value object
	-- manually indicates such a change has occured via `change()`.
	return false
end

function class._peek<T, S>(
	self: Self<T, S>
): T
	return self._value :: any
end

return Value :: Types.ValueConstructor