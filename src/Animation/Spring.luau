--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	A specialised state object for following a goal state smoothly over time,
	using physics to shape the motion.

	https://elttob.uk/Fusion/0.3/api-reference/animation/types/spring/
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
-- Memory
local checkLifetime = require(Package.Memory.checkLifetime)
-- Graph
local depend = require(Package.Graph.depend)
local change = require(Package.Graph.change)
local evaluate = require(Package.Graph.evaluate)
-- State
local castToState = require(Package.State.castToState)
local peek = require(Package.State.peek)
-- Animation
local ExternalTime = require(Package.Animation.ExternalTime)
local Stopwatch = require(Package.Animation.Stopwatch)
local packType = require(Package.Animation.packType)
local unpackType = require(Package.Animation.unpackType)
local springCoefficients = require(Package.Animation.springCoefficients)
-- Utility
local nicknames = require(Package.Utility.nicknames)

local EPSILON = 0.00001

type Self<T> = Types.Spring<T> & {
	_activeDamping: number,
	_activeGoal: T,
	_activeLatestP: {number},
	_activeLatestV: {number},
	_activeNumSprings: number,
	_activeSpeed: number,
	_activeStartP: {number},
	_activeStartV: {number},
	_activeTargetP: {number},
	_activeType: string,
	_speed: Types.UsedAs<number>,
	_damping: Types.UsedAs<number>,
	_goal: Types.UsedAs<T>,
	_stopwatch: Stopwatch.Stopwatch
}

local class = {}
class.type = "State"
class.kind = "Spring"
class.timeliness = "eager"

local METATABLE = table.freeze {__index = class}

local function Spring<T>(
	scope: Types.Scope<unknown>,
	goal: Types.UsedAs<T>,
	speed: Types.UsedAs<number>?,
	damping: Types.UsedAs<number>?
): Types.Spring<T>
	local createdAt = os.clock()
	if typeof(scope) ~= "table" or castToState(scope) ~= nil then
		External.logError("scopeMissing", nil, "Springs", "myScope:Spring(goalState, speed, damping)")
	end

	local goalState = castToState(goal)
	local stopwatch = nil
	if goalState ~= nil then
		stopwatch = Stopwatch(scope, ExternalTime(scope))
		stopwatch:unpause()
	end

	local speed = speed or 10
	local damping = damping or 1

	local self: Self<T> = setmetatable(
		{
			createdAt = createdAt,
			dependencySet = {},
			dependentSet = {},
			lastChange = nil,
			scope = scope,
			validity = "invalid",
			_activeDamping = -1,
			_activeGoal = nil,
			_activeLatestP = {},
			_activeLatestV = {},
			_activeNumSprings = 0,
			_activeSpeed = -1,
			_activeStartP = {},
			_activeStartV = {},
			_activeTargetP = {},
			_activeType = "",
			_damping = damping,
			_EXTREMELY_DANGEROUS_usedAsValue = peek(goal),
			_goal = goal,
			_speed = speed,
			_stopwatch = stopwatch
		},
		METATABLE
	) :: any
	local destroy = function()
		self.scope = nil
		for dependency in pairs(self.dependencySet) do
			dependency.dependentSet[self] = nil
		end
	end
	self.oldestTask = destroy
	nicknames[self.oldestTask] = "Spring"
	table.insert(scope, destroy)
	
	if goalState ~= nil then
		checkLifetime.bOutlivesA(
			scope, self.oldestTask,
			goalState.scope, goalState.oldestTask,
			checkLifetime.formatters.animationGoal
		)
	end
	local speedState = castToState(speed)
	if speedState ~= nil then
		checkLifetime.bOutlivesA(
			scope, self.oldestTask,
			speedState.scope, speedState.oldestTask,
			checkLifetime.formatters.parameter, "speed"
		)
	end
	local dampingState = castToState(damping)
	if dampingState ~= nil then
		checkLifetime.bOutlivesA(
			scope, self.oldestTask,
			dampingState.scope, dampingState.oldestTask,
			checkLifetime.formatters.parameter, "damping"
		)
	end

	-- Eagerly evaluated objects need to evaluate themselves so that they're
	-- valid at all times.
	evaluate(self, true)

	return self
end

function class.addVelocity<T>(
	self: Self<T>,
	deltaValue: T
): ()
	evaluate(self, false) -- ensure the _active params are up to date
	local deltaType = typeof(deltaValue)
	if deltaType ~= self._activeType then
		External.logError("springTypeMismatch", nil, deltaType, self._activeType)
	end
	local newStartV = unpackType(deltaValue, deltaType)
	for index, velocity in self._activeLatestV do
		newStartV[index] += velocity
	end
	self._activeStartP = table.clone(self._activeLatestP)
	self._activeStartV = newStartV
	self._stopwatch:zero()
	self._stopwatch:unpause()
	change(self)
end

function class.get<T>(
	self: Self<T>
): never
	return External.logError("stateGetWasRemoved")
end

function class.setPosition<T>(
	self: Self<T>,
	newValue: T
): ()
	evaluate(self, false) -- ensure the _active params are up to date
	local newType = typeof(newValue)
	if newType ~= self._activeType then
		External.logError("springTypeMismatch", nil, newType, self._activeType)
	end
	self._activeStartP = unpackType(newValue, newType)
	self._activeStartV = table.clone(self._activeLatestV)
	self._stopwatch:zero()
	self._stopwatch:unpause()
	change(self)
end

function class.setVelocity<T>(
	self: Self<T>,
	newValue: T
): ()
	evaluate(self, false) -- ensure the _active params are up to date
	local newType = typeof(newValue)
	if newType ~= self._activeType then
		External.logError("springTypeMismatch", nil, newType, self._activeType)
	end
	self._activeStartP = table.clone(self._activeLatestP)
	self._activeStartV = unpackType(newValue, newType)
	self._stopwatch:zero()
	self._stopwatch:unpause()
	change(self)
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
	-- depend(self, goal)
	local nextFrameGoal = peek(goal)
	-- Protect against NaN goals.
	if nextFrameGoal ~= nextFrameGoal then
		External.logWarn("springNanGoal")
		return false
	end
	local nextFrameGoalType = typeof(nextFrameGoal)
	local discontinuous = nextFrameGoalType ~= self._activeType

	local stopwatch = self._stopwatch :: Stopwatch.Stopwatch
	local elapsed = peek(stopwatch)
	depend(self, stopwatch)

	local oldValue = self._EXTREMELY_DANGEROUS_usedAsValue
	local newValue: T

	if discontinuous then
		-- Propagate changes in type instantly throughout the whole reactive
		-- graph, even if simulation is logically one frame behind, because it
		-- makes the whole graph behave more consistently.
		newValue = nextFrameGoal
	elseif elapsed <= 0 then
		newValue = oldValue
	else
		-- Calculate spring motion.
		-- IMPORTANT: use the parameters from last frame, not this frame. We're
		-- integrating the motion that happened over the last frame, after all.
		-- The stopwatch will have captured the length of time needed correctly.
		local posPos, posVel, velPos, velVel = springCoefficients(
			elapsed, 
			self._activeDamping, 
			self._activeSpeed
		)
		local isMoving = false
		for index = 1, self._activeNumSprings do
			local startP = self._activeStartP[index]
			local targetP = self._activeTargetP[index]
			local startV = self._activeStartV[index]
			local startD = startP - targetP
			local latestD = startD * posPos + startV * posVel
			local latestV = startD * velPos + startV * velVel
			if latestD ~= latestD or latestV ~= latestV then
				External.logWarn("springNanMotion")
				latestD, latestV = 0, 0
			end
			if math.abs(latestD) > EPSILON or math.abs(latestV) > EPSILON then
				isMoving = true
			end
			local latestP = latestD + targetP
			self._activeLatestP[index] = latestP
			self._activeLatestV[index] = latestV
		end
		-- Sleep and snap to goal if the motion has decayed to a negligible amount.
		if not isMoving then
			for index = 1, self._activeNumSprings do
				self._activeLatestP[index] = self._activeTargetP[index]
			end
			-- TODO: figure out how to do sleeping correctly for single frame
			-- changes
			-- stopwatch:pause()
			-- stopwatch:zero()
		end
		-- Pack springs into final value.
		newValue = packType(self._activeLatestP, self._activeType) :: any
	end

	-- Reconfigure spring when any of its parameters are changed.
	-- This should happen after integrating the last frame's motion.
	-- NOTE: don't need to add a dependency on these objects! they do not cause
	-- a spring to wake from sleep, so the stopwatch dependency is sufficient.
	local nextFrameSpeed = peek(self._speed) :: number
	local nextFrameDamping = peek(self._damping) :: number
	if
		discontinuous or
		nextFrameGoal ~= self._activeGoal or
		nextFrameSpeed ~= self._activeSpeed or
		nextFrameDamping ~= self._activeDamping
	then
		self._activeTargetP = unpackType(nextFrameGoal, nextFrameGoalType)
		self._activeNumSprings = #self._activeTargetP
		if discontinuous then
			self._activeStartP = table.clone(self._activeTargetP)
			self._activeLatestP = table.clone(self._activeTargetP)
			self._activeStartV = table.create(self._activeNumSprings, 0)
			self._activeLatestV = table.create(self._activeNumSprings, 0)
		else
			self._activeStartP = table.clone(self._activeLatestP)
			self._activeStartV = table.clone(self._activeLatestV)
		end
		self._activeType = nextFrameGoalType
		self._activeGoal = nextFrameGoal
		self._activeDamping = nextFrameDamping
		self._activeSpeed = nextFrameSpeed
		stopwatch:zero()
		stopwatch:unpause()
	end

	-- Push update and check for similarity.
	-- Don't need to use the similarity test here because this code doesn't
	-- deal with tables, and NaN is already guarded against, so the similarity
	-- test doesn't actually add any new safety here.
	self._EXTREMELY_DANGEROUS_usedAsValue = newValue
	return oldValue ~= newValue
end

table.freeze(class)
return Spring :: Types.SpringConstructor