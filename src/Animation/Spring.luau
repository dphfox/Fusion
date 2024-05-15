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
local whichLivesLonger = require(Package.Memory.whichLivesLonger)
-- Graph
local depend = require(Package.Graph.depend)
local change = require(Package.Graph.change)
-- State
local castToState = require(Package.State.castToState)
local peek = require(Package.State.peek)
-- Animation
local ExternalTime = require(Package.Animation.ExternalTime)
local Stopwatch = require(Package.Animation.Stopwatch)
local unpackType = require(Package.Animation.unpackType)

type Self<T> = Types.Spring<T> & {
	_activeLatestP: {number},
	_activeLatestV: {number},
	_activeStartP: {number},
	_activeStartV: {number},
	_activeType: string,

	_speed: Types.UsedAs<number>,
	_damping: Types.UsedAs<number>,
	_goal: Types.UsedAs<T>,
	_stopwatch: Stopwatch.Stopwatch
}

local class = {}
class.type = "State"
class.kind = "Spring"
class.timeliness = "lazy"

local METATABLE = {}
METATABLE.__index = class

local function Spring<T>(
	scope: Types.Scope<unknown>,
	goal: Types.UsedAs<T>,
	speed: Types.UsedAs<number>?,
	damping: Types.UsedAs<number>?
): Self<T>
	if typeof(scope) ~= "table" or castToState(scope) ~= nil then
		External.logError("scopeMissing", nil, "Springs", "myScope:Spring(goalState, speed, damping)")
	end

	local goalState = castToState(goal)
	local stopwatch = nil
	if goalState ~= nil then
		stopwatch = Stopwatch(scope, ExternalTime(scope))
	end

	local self: Self<T> = setmetatable(
		{
			dependencySet = {},
			dependentSet = {},
			lastChange = nil,
			scope = scope,
			validity = "invalid",
			_damping = damping or 1,
			_EXTREMELY_DANGEROUS_usedAsValue = nil,
			_goal = goal,
			_speed = speed or 10,
			_stopwatch = stopwatch
		},
		METATABLE
	) :: any
	table.insert(scope, self)
	
	if goalState ~= nil then
		depend(self, goalState) -- TODO: lifetime analysis
	end
	local speedState = castToState(speed)
	if speedState ~= nil then
		depend(self, speedState) -- TODO: lifetime analysis
	end
	local dampingState = castToState(damping)
	if dampingState ~= nil then
		depend(self, dampingState) -- TODO: lifetime analysis
	end

	return self
end

function class.addVelocity<T>(
	self: Self<T>,
	deltaValue: T
): ()
	local deltaType = typeof(deltaValue)
	if deltaType ~= self._activeType then
		External.logError("springTypeMismatch", nil, deltaType, self._activeType)
	end
	local newStartV = unpackType(deltaValue, deltaType)
	for index, velocity in self._activeLatestV do
		newStartV[index] += velocity
	end
	self._activeStartP = self._activeLatestP
	self._activeStartV = unpackType(newValue, newType)
	self._stopwatch:zero()
	change(self)
end

function class.destroy<T>(
	self: Self<T>
): ()
	if self.scope == nil then
		External.logError("destroyedTwice", nil, "Spring")
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

function class.setPosition<T>(
	self: Self<T>,
	newValue: T
): ()
	local newType = typeof(newValue)
	if newType ~= self._activeType then
		External.logError("springTypeMismatch", nil, newType, self._activeType)
	end
	self._activeStartP = unpackType(newValue, newType)
	self._activeStartV = self._activeLatestV
	self._stopwatch:zero()
	change(self)
end

function class.setVelocity<T>(
	self: Self<T>,
	newValue: T
): ()
	local newType = typeof(newValue)
	if newType ~= self._activeType then
		External.logError("springTypeMismatch", nil, newType, self._activeType)
	end
	self._activeStartP = self._activeLatestP
	self._activeStartV = unpackType(newValue, newType)
	self._stopwatch:zero()
	change(self)
end

function class._evaluate<T>(
	self: Self<T>
): boolean
	local goalValue = peek(self._goal)

	-- figure out if this was a goal change or a speed/damping change
	if goalValue == self._goalValue then
		-- speed/damping change
		local damping = peek(self._damping)
		if typeof(damping) ~= "number" then
			External.logErrorNonFatal("mistypedSpringDamping", nil, typeof(damping))
		elseif damping < 0 then
			External.logErrorNonFatal("invalidSpringDamping", nil, damping)
		else
			self._currentDamping = damping
		end

		local speed = peek(self._speed)
		if typeof(speed) ~= "number" then
			External.logErrorNonFatal("mistypedSpringSpeed", nil, typeof(speed))
		elseif speed < 0 then
			External.logErrorNonFatal("invalidSpringSpeed", nil, speed)
		else
			self._currentSpeed = speed
		end

		return false
	else
		-- goal change - reconfigure spring to target new goal
		self._goalValue = goalValue

		local oldType = self._currentType
		local newType = typeof(goalValue)
		self._currentType = newType

		local springGoals = unpackType(goalValue, newType)
		local numSprings = #springGoals
		self._springGoals = springGoals

		if newType ~= oldType then
			-- if the type changed, snap to the new value and rebuild the
			-- position and velocity tables
			self._currentValue = self._goalValue

			local springPositions = table.create(numSprings, 0)
			local springVelocities = table.create(numSprings, 0)
			for index, springGoal in ipairs(springGoals) do
				springPositions[index] = springGoal
			end
			self._springPositions = springPositions
			self._springVelocities = springVelocities

			-- the spring may have been animating before, so stop that
			SpringScheduler.remove(self)
			return true

			-- otherwise, the type hasn't changed, just the goal...
		elseif numSprings == 0 then
			-- if the type isn't animatable, snap to the new value
			self._currentValue = self._goalValue
			return true

		else
			-- if it's animatable, let it animate to the goal
			SpringScheduler.add(self)
			return false
		end
	end
end

function class._peek<T>(
	self: Self<T>
): T
	return self._currentValue
end

return Spring