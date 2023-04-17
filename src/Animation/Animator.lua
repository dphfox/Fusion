--!nonstrict

--[[
	Provides a reactive interface for dealing with animation curve families.
]]

-- TODO: type annotate this file

local Package = script.Parent.Parent
-- Logging
local logError = require(Package.Logging.logError)
-- State
local isState = require(Package.State.isState)

local class = {}

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}

--[[
	Called when a new animation curve family is supplied. A new curve is
	defined with the current conditions of the animator. Returns true if the
	new curve did not preserve the position of the animator.
]]
function class:update(): boolean
	-- TODO
	return false
end

--[[
	Returns the interior value of this state object.
]]
function class:_peek(): any
	-- TODO
	return nil
end

function class:get()
	logError("stateGetWasRemoved")
end

local function Animator(
	curveFamily,
	timer
)
	if timer == nil then
		-- TODO; when timers are added, create a default timer here
		error("TODO: default timer is not created yet")
	end

	local self = setmetatable({
		type = "State",
		kind = "Animator",
		dependencySet = {},
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_curveFamily = curveFamily,
		_timer = timer
	}, CLASS_METATABLE)

	if isState(curveFamily) then
		self.dependencySet[curveFamily] = true
		curveFamily.dependentSet[self] = true
	end

	return self
end

return Animator