--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Constructs a new computed state object, which follows the value of another
	state object using a spring simulation.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
local External = require(Package.External)
local unpackType = require(Package.Animation.unpackType)
local SpringScheduler = require(Package.Animation.SpringScheduler)
local change = require(Package.Graph.change)
local castToState = require(Package.State.castToState)
local peek = require(Package.State.peek)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

type Self<T> = Types.Spring<T> & {
	_speed: Types.UsedAs<number>,
	_damping: Types.UsedAs<number>,
	_goal: Types.UsedAs<T>,
	_goalValue: T,

	_currentType: string,
	_currentValue: T,
	_currentSpeed: number,
	_currentDamping: number,

	_springPositions: {number},
	_springGoals: {number},
	_springVelocities: {number},

	_lastSchedule: number,
	_startDisplacements: {number},
	_startVelocities: {number}
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
	-- apply defaults for speed and damping
	if speed == nil then
		speed = 10
	end
	if damping == nil then
		damping = 1
	end

	local dependencySet: {[Types.GraphObject]: unknown} = {}
	local goalIsState = castToState(goal) ~= nil
	if goalIsState then
		local goal = goal :: Types.StateObject<T>
		dependencySet[goal] = true
	end
	if castToState(speed) then
		local speed = speed :: Types.StateObject<number>
		dependencySet[speed] = true
	end
	if castToState(damping) then
		local damping = damping :: Types.StateObject<number>
		dependencySet[damping] = true
	end

	local self: Self<T> = setmetatable(
		{
			dependencySet = dependencySet,
			dependentSet = {},
			scope = scope,
			_currentDamping = peek(damping),
			_currentSpeed = peek(speed),
			_currentType = nil,
			_currentValue = nil,
			_damping = damping,
			_goal = goal,
			_goalValue = nil,
			_lastSchedule = -math.huge,
			_speed = speed,
			_springGoals = nil,
			_springPositions = nil,
			_springVelocities = nil,
			_startDisplacements = {},
			_startVelocities = {}
		},
		METATABLE
	) :: any

	table.insert(scope, self)
	
	if goalIsState then
		local goal = goal :: Types.StateObject<T>
		if goal.scope == nil then
			External.logError("useAfterDestroy", nil, `The {goal.kind} object`, `the Spring that is following it`)
		elseif whichLivesLonger(scope, self, goal.scope, goal) == "definitely-a" then
			External.logWarn("possiblyOutlives", `The {goal.kind} object`, `the Spring that is following it`)
		end
		-- add this object to the goal state's dependent set
		goal.dependentSet[self] = true
	end

	self:update()

	return self
end

function class.addVelocity<T>(
	self: Self<T>,
	deltaValue: T
): ()
	local deltaType = typeof(deltaValue)
	if deltaType ~= self._currentType then
		External.logError("springTypeMismatch", nil, deltaType, self._currentType)
	end
	local springDeltas = unpackType(deltaValue, deltaType)
	for index, delta in ipairs(springDeltas) do
		self._springVelocities[index] += delta
	end
	SpringScheduler.add(self)
end

function class.destroy<T>(
	self: Self<T>
): ()
	if self.scope == nil then
		External.logError("destroyedTwice", nil, "Spring")
	end
	SpringScheduler.remove(self)
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
	if newType ~= self._currentType then
		External.logError("springTypeMismatch", nil, newType, self._currentType)
	end
	self._springPositions = unpackType(newValue, newType)
	self._currentValue = newValue
	SpringScheduler.add(self)
	change(self)
end

function class.setVelocity<T>(
	self: Self<T>,
	newValue: T
): ()
	local newType = typeof(newValue)
	if newType ~= self._currentType then
		External.logError("springTypeMismatch", nil, newType, self._currentType)
	end
	self._springVelocities = unpackType(newValue, newType)
	SpringScheduler.add(self)
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