--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Constructs a new computed state object, which follows the value of another
	state object using a tween.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
-- Graph
local depend = require(Package.Graph.depend)
-- State
local castToState = require(Package.State.castToState)
local peek = require(Package.State.peek)
-- Animation
local ExternalTime = require(Package.Animation.ExternalTime)
local EventTimer = require(Package.Animation.EventTimer)
local lerpType = require(Package.Animation.lerpType)

export type Self<T> = Types.Tween<T> & {
	_goal: Types.UsedAs<T>,
	_eventTimer: Types.StateObject<number>?,
	_tweenFrom: T,
	_tweenTo: T,
	_awake: boolean
}

local class = {}
class.type = "State"
class.kind = "Tween"
class.timeliness = "lazy"

local METATABLE = {}
METATABLE.__index = class

local function Tween<T>(
	scope: Types.Scope<unknown>,
	goal: Types.UsedAs<T>,
	tweenInfo: Types.UsedAs<TweenInfo>?
): Types.Tween<T>
	if castToState(scope) then
		External.logError("scopeMissing", nil, "Tweens", "myScope:Tween(goalState, tweenInfo)")
	end

	-- apply defaults for tween info
	if tweenInfo == nil then
		tweenInfo = TweenInfo.new()
	end

	local goalState = castToState(goal)
	local eventTimer = nil

	if goalState ~= nil then
		eventTimer = EventTimer(scope, goalState, ExternalTime(scope))
	end

	local self: Self<T> = setmetatable(
		{
			dependencySet = {},
			dependentSet = {},
			lastChange = nil,
			scope = scope,
			validity = "invalid",
			_EXTREMELY_DANGEROUS_usedAsValue = nil,
			_goal = goal,
			_eventTimer = eventTimer,
			_tweenFrom = nil,
			_tweenTo = nil,
			_awake = false
		},
		METATABLE
	) :: any

	table.insert(scope, self)
	
	return self
end

function class.destroy<T>(
	self: Self<T>
): ()
	if self.scope == nil then
		External.logError("destroyedTwice", nil, "Tween")
	end
	self.scope = nil
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
end

function class.get<T>(
	self: Self<T>
): never
	return External.logError("stateGetWasRemoved")
end

function class._evaluate<T>(
	self: Self<T>
): boolean
	local goal = castToState(self._goal)
	-- Allow non-state goals to pass through transparently.
	if goal == nil then
		self._EXTREMELY_DANGEROUS_usedAsValue = self._goal :: T
		return false
	end
	depend(self, goal)
	local newTweenTo = peek(goal)
	-- Protect against NaN goals.
	if newTweenTo ~= newTweenTo then
		External.logWarn("tweenNanGoal")
		return false
	end
	-- Respond to changes in the goal state.
	if self._tweenTo ~= newTweenTo then
		self._tweenFrom = self._tweenTo
		self._tweenTo = newTweenTo
		self._awake = true
	end
	-- Snap to the goal and sleep if no animation can occur.
	if
		self._tweenFrom == self._tweenTo or -- endpoints match
		typeof(self._tweenTo) ~= typeof(self._tweenFrom) or -- type difference
		self._tweenFrom ~= self._tweenFrom -- last goal was NaN
	then
		self._tweenFrom = self._tweenTo
		self._awake = false
	end
	local duration = 1
	local elapsed = duration
	-- Don't depend on the timer while asleep.
	if self._awake then
		local eventTimer = self._eventTimer :: Types.StateObject<number>
		depend(self, eventTimer)
		elapsed = peek(eventTimer)
	end
	-- Go to sleep if the animation is done.
	if elapsed >= duration then
		self._awake = false
	end	
	-- Compute actual tweened value.
	local ratio = elapsed / duration -- TODO: tween ratios
	local oldValue = self._EXTREMELY_DANGEROUS_usedAsValue
	local newValue = lerpType(
		self._tweenFrom,
		self._tweenTo,
		ratio
	) :: T
	-- Protect against NaN after motion.
	if newValue ~= newValue then
		External.logWarn("tweenNanMotion")
		newValue = self._tweenTo
	end
	-- Push update and check for similarity.
	-- Don't need to use the similarity test here because this code doesn't
	-- deal with tables, and NaN is already guarded against, so the similarity
	-- test doesn't actually add any new safety here.
	self._EXTREMELY_DANGEROUS_usedAsValue = newValue
	return oldValue ~= newValue
end

return Tween