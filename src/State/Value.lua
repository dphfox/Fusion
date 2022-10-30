--!nonstrict

--[[
	Constructs and returns objects which can be used to model independent
	reactive state.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local useDependency = require(Package.Dependencies.useDependency)
local initDependency = require(Package.Dependencies.initDependency)
local updateAll = require(Package.Dependencies.updateAll)
local logWarn = require(Package.Logging.logWarn)
local isSimilar = require(Package.Utility.isSimilar)
local needsDestruction = require(Package.Utility.needsDestruction)

local class = {}

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}

--[[
	Returns the value currently stored in this State object.
	The state object will be registered as a dependency unless `asDependency` is
	false.
]]
function class:get(asDependency: boolean?): any
	if asDependency ~= false then
		useDependency(self)
	end
	return self._value
end

--[[
	Updates the value stored in this State object.

	If `force` is enabled, this will skip equality checks and always update the
	state object and any dependents - use this with care as this can lead to
	unnecessary updates.
]]
function class:set(newValue: any, force: boolean?)
	if self._destructor == nil and needsDestruction(newValue) then
		logWarn("destructorNeededValue")
	end

	local oldValue = self._value
	if force or not isSimilar(oldValue, newValue) then
		self._value = newValue
		if self._destructor ~= nil then
			self._destructor(oldValue)
		end
		updateAll(self)
	end
end

local function Value<T>(initialValue: T, destructor: (T) -> ()?): Types.State<T>
	local self = setmetatable({
		type = "State",
		kind = "Value",
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_value = initialValue,
		_destructor = destructor
	}, CLASS_METATABLE)

	if self._destructor == nil and needsDestruction(initialValue) then
		logWarn("destructorNeededValue")
	end

	initDependency(self)

	return self
end

return Value