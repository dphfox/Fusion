--!nonstrict

--[[
	Constructs and returns objects which can be used to model lazy derived
	reactive state.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
-- Logging
local logError = require(Package.Logging.logError)
-- State
local calculate = require(Package.State.calculate)
local shouldCalculate = require(Package.State.shouldCalculate)
-- Utility
local xtypeof = require(Package.Utility.xtypeof)

local class = {}

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}

--[[
	Recalculates this Computed's cached value and dependencies.
	Returns true if it changed, or false if it's identical.

	If `force` is enabled, this will skip `shouldCalculate()` checks and will
	always update the state object - use this with care as this can lead to
	unnecessary updates.
]]
function class:update(force: boolean?): boolean
	if not force and not shouldCalculate(self) then
		self:_change()
		return false
	end
	self._didChange = false

	return calculate(self)
end

--[[
	Returns the interior value of this state object.
]]
function class:_peek(): any
	if self._didChange then
		self:update(true)
	end
	return self._value
end

--[[
	Sets _didChange value to true for this Computed and all its dependent
	Computeds.
]]
function class:_change()
	self._didChange = true
	for subDependentState: Types.Computed<any> in self.dependentSet do
		if xtypeof(subDependentState) == "State" and subDependentState.kind == "Computed" then
			subDependentState:_change()
		end
	end
end

function class:get()
	logError("stateGetWasRemoved")
end

local function Computed<T>(processor: () -> T, destructor: ((T) -> ())?): Types.Computed<T>
	local dependencySet = {}
	local self = setmetatable({
		type = "State",
		kind = "Computed",
		dependencySet = dependencySet,
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_oldDependencySet = {},
		_processor = processor,
		_destructor = destructor,
		_didChange = true,
		_value = nil,
	}, CLASS_METATABLE)

	return self
end

return Computed
