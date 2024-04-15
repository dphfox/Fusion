--!strict
--!nolint LocalShadow

--[[
	Constructs a new computed state object, which follows the value of another
	state object using a tween.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
local External = require(Package.External)
local TweenScheduler = require(Package.Animation.TweenScheduler)
local logError = require(Package.Logging.logError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local isState = require(Package.State.isState)
local peek = require(Package.State.peek)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)
local logWarn = require(Package.Logging.logWarn)

local class = {}
class.type = "State"
class.kind = "Tween"

local CLASS_METATABLE = {__index = class}

--[[
	Called when the goal state changes value; this will initiate a new tween.
	Returns false as the current value doesn't change right away.
]]
function class:update(): boolean
	local self = self :: InternalTypes.Tween<unknown>
	local goalValue = peek(self._goalState)

	-- if the goal hasn't changed, then this is a TweenInfo change.
	-- in that case, if we're not currently animating, we can skip everything
	if goalValue == self._nextValue and not self._currentlyAnimating then
		return false
	end

	local tweenInfo = peek(self._tweenInfo)

	-- if we receive a bad TweenInfo, then error and stop the update
	if typeof(tweenInfo) ~= "TweenInfo" then
		logErrorNonFatal("mistypedTweenInfo", nil, typeof(tweenInfo))
		return false
	end

	self._prevValue = self._currentValue
	self._nextValue = goalValue

	self._currentTweenStartTime = External.lastUpdateStep()
	self._currentTweenInfo = tweenInfo

	local tweenDuration = tweenInfo.DelayTime + tweenInfo.Time
	if tweenInfo.Reverses then
		tweenDuration += tweenInfo.Time
	end
	tweenDuration *= tweenInfo.RepeatCount + 1
	self._currentTweenDuration = tweenDuration

	-- start animating this tween
	TweenScheduler.add(self)

	return false
end

--[[
	Returns the interior value of this state object.
]]
function class:_peek(): unknown
	local self = self :: InternalTypes.Tween<unknown>
	return self._currentValue
end

function class:get()
	logError("stateGetWasRemoved")
end

function class:destroy()
	local self = self :: InternalTypes.Tween<unknown>
	if self.scope == nil then
		logError("destroyedTwice", nil, "Tween")
	end
	TweenScheduler.remove(self)
	self.scope = nil
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
end

local function Tween<T>(
	scope: Types.Scope<unknown>,
	goalState: Types.StateObject<T>,
	tweenInfo: Types.CanBeState<TweenInfo>?
): Types.Tween<T>
	if isState(scope) then
		logError("scopeMissing", nil, "Tweens", "myScope:Tween(goalState, tweenInfo)")
	end
	local currentValue = peek(goalState)

	-- apply defaults for tween info
	if tweenInfo == nil then
		tweenInfo = TweenInfo.new()
	end

	local dependencySet: {[Types.Dependency]: unknown} = {[goalState] = true}
	local tweenInfoIsState = isState(tweenInfo)
	if tweenInfoIsState then
		local tweenInfo = tweenInfo :: Types.StateObject<TweenInfo>
		dependencySet[tweenInfo] = true
	end

	local startingTweenInfo = peek(tweenInfo)
	-- If we start with a bad TweenInfo, then we don't want to construct a Tween
	if typeof(startingTweenInfo) ~= "TweenInfo" then
		logError("mistypedTweenInfo", nil, typeof(startingTweenInfo))
	end

	local self = setmetatable({
		scope = scope,
		dependencySet = dependencySet,
		dependentSet = {},
		_goalState = goalState,
		_tweenInfo = tweenInfo,
		_tweenInfoIsState = tweenInfoIsState,

		_prevValue = currentValue,
		_nextValue = currentValue,
		_currentValue = currentValue,

		-- store current tween into separately from 'real' tween into, so it
		-- isn't affected by :setTweenInfo() until next change
		_currentTweenInfo = tweenInfo,
		_currentTweenDuration = 0,
		_currentTweenStartTime = 0,
		_currentlyAnimating = false
	}, CLASS_METATABLE)
	local self = (self :: any) :: InternalTypes.Tween<T>

	table.insert(scope, self)
	if goalState.scope == nil then
		logError("useAfterDestroy", nil, `The {goalState.kind} object`, `the Tween that is following it`)
	elseif whichLivesLonger(scope, self, goalState.scope, goalState) == "definitely-a" then
		logWarn("possiblyOutlives", `The {goalState.kind} object`, `the Tween that is following it`)
	end

	-- add this object to the goal state's dependent set
	goalState.dependentSet[self] = true

	return self
end

return Tween