--[[
	Constructs a new computed state object, which follows the value of another
	state object using a tween.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local TweenScheduler = require(Package.Animation.TweenScheduler)
local useDependency = require(Package.Dependencies.useDependency)
local initDependency = require(Package.Dependencies.initDependency)

local class = {}

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}

local ENABLE_PARAM_SETTERS = false

--[[
	Returns the current value of this Tween object.
	The object will be registered as a dependency unless `asDependency` is false.
]]
function class:get(asDependency: boolean?)
	if asDependency ~= false then
		useDependency(self)
	end
	return self._currentValue
end

--[[
	Called when the goal state changes value; this will initiate a new tween.
	Returns false as the current value doesn't change right away.
]]
function class:update()
	self._prevValue = self._currentValue
	self._nextValue = self._goalState:get(false)

	self._currentTweenStartTime = os.clock()
	self._currentTweenInfo = self._tweenInfo

	local tweenDuration = self._tweenInfo.DelayTime + self._tweenInfo.Time
	if self._tweenInfo.Reverses then
		tweenDuration += self._tweenInfo.Time
	end
	tweenDuration *= math.max(self._tweenInfo.RepeatCount, 1)
	self._currentTweenDuration = tweenDuration

	-- start animating this tween
	TweenScheduler.add(self)
	return false
end

if ENABLE_PARAM_SETTERS then

	--[[
		Specifies a new TweenInfo to use when the goal state changes in the future.
	]]
	function class:setTweenInfo(newTweenInfo: TweenInfo)
		self._tweenInfo = newTweenInfo
	end

end

local function Tween(goalState: Types.State<Types.Animatable>, tweenInfo: TweenInfo?)
	local currentValue = goalState:get(false)

	local self = setmetatable({
		type = "State",
		kind = "Tween",
		dependencySet = {[goalState] = true},
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_goalState = goalState,
		_tweenInfo = tweenInfo or TweenInfo.new(),

		_prevValue = currentValue,
		_nextValue = currentValue,
		_currentValue = currentValue,

		-- store current tween into separately from 'real' tween into, so it
		-- isn't affected by :setTweenInfo() until next change
		_currentTweenInfo = tweenInfo,
		_currentTweenDuration = 0,
		_currentTweenStartTime = 0
	}, CLASS_METATABLE)

	initDependency(self)
	-- add this object to the goal state's dependent set
	goalState.dependentSet[self] = true

	return self
end

return Tween