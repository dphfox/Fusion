--!nonstrict

--[[
	Constructs and returns objects which can be used to model derived reactive
	state.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
-- Logging
local logError = require(Package.Logging.logError)
-- State
local calculate = require(Package.State.calculate)

local class = {}

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}

--[[
	Recalculates this Eager's cached value and dependencies.
	Returns true if it changed, or false if it's identical.
]]
function class:update(): boolean
	return calculate(self)
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

local function Eager<T>(processor: () -> T, destructor: ((T) -> ())?): Types.Eager<T>
	local dependencySet = {}
	local self = setmetatable({
		type = "State",
		kind = "Eager",
		dependencySet = dependencySet,
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_oldDependencySet = {},
		_processor = processor,
		_destructor = destructor,
		_value = nil,
	}, CLASS_METATABLE)

	self:update()

	return self
end

return Eager
