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
local InternalTypes = require(Package.InternalTypes)
local External = require(Package.External)
local TweenScheduler = require(Package.Animation.TweenScheduler)
local isState = require(Package.State.isState)
local peek = require(Package.State.peek)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

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
	local goalValue = peek(self._goal)

	-- if the goal hasn't changed, then this is a TweenInfo change.
	-- in that case, if we're not currently animating, we can skip everything
	if goalValue == self._nextValue and not self._currentlyAnimating then
		return false
	end

	local tweenInfo = peek(self._tweenInfo)

	-- if we receive a bad TweenInfo, then error and stop the update
	if typeof(tweenInfo) ~= "TweenInfo" then
		External.logErrorNonFatal("mistypedTweenInfo", nil, typeof(tweenInfo))
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
	External.logError("stateGetWasRemoved")
end

local function Tween<T>(
	scope: Types.Scope<unknown>,
	goal: Types.UsedAs<T>,
	tweenInfo: Types.UsedAs<TweenInfo>?
): Types.Tween<T>
	if isState(scope) then
		External.logError("scopeMissing", nil, "Tweens", "myScope:Tween(goalState, tweenInfo)")
	end
	local currentValue = peek(goal)

	-- apply defaults for tween info
	if tweenInfo == nil then
		tweenInfo = TweenInfo.new()
	end

	local dependencySet: {[Types.Dependency]: unknown} = {}

	local goalIsState = isState(goal)
	if goalIsState then
		local goal = goal :: Types.StateObject<T>
		dependencySet[goal] = true
	end

	local tweenInfoIsState = isState(tweenInfo)
	if tweenInfoIsState then
		local tweenInfo = tweenInfo :: Types.StateObject<TweenInfo>
		dependencySet[tweenInfo] = true
	end

	local startingTweenInfo = peek(tweenInfo)
	-- If we start with a bad TweenInfo, then we don't want to construct a Tween
	if typeof(startingTweenInfo) ~= "TweenInfo" then
		External.logError("mistypedTweenInfo", nil, typeof(startingTweenInfo))
	end

	local self = setmetatable({
		scope = scope,
		dependencySet = dependencySet,
		dependentSet = {},
		_goal = goal,
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

	local destroy = function()
		TweenScheduler.remove(self)
		self.scope = nil
		for dependency in pairs(self.dependencySet) do
			dependency.dependentSet[self] = nil
		end
	end
	self.oldestTask = destroy
	table.insert(scope, destroy)
	
	if goalIsState then
		local goal = goal :: any
		if goal.scope == nil then
			External.logError("useAfterDestroy", nil, `The {goal.kind} object`, `the Tween that is following it`)
		elseif whichLivesLonger(scope, self.oldestTask, goal.scope, goal.oldestTask) == "definitely-a" then
			External.logWarn("possiblyOutlives", `The {goal.kind} object`, `the Tween that is following it`)
		end
		-- add this object to the goal state's dependent set
		goal.dependentSet[self] = true
	end

	return self
end

return Tween