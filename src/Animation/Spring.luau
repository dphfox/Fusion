--!strict
--!nolint LocalShadow

--[[
	Constructs a new computed state object, which follows the value of another
	state object using a spring simulation.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
local logError = require(Package.Logging.logError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local unpackType = require(Package.Animation.unpackType)
local SpringScheduler = require(Package.Animation.SpringScheduler)
local updateAll = require(Package.State.updateAll)
local isState = require(Package.State.isState)
local peek = require(Package.State.peek)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)
local logWarn = require(Package.Logging.logWarn)

local class = {}
class.type = "State"
class.kind = "Spring"

local CLASS_METATABLE = {__index = class}

--[[
	Sets the position of the internal springs, meaning the value of this
	Spring will jump to the given value. This doesn't affect velocity.

	If the type doesn't match the current type of the spring, an error will be
	thrown.
]]
function class:setPosition(
	newValue: Types.Animatable
)
	local self = self :: InternalTypes.Spring<unknown>
	local newType = typeof(newValue)
	if newType ~= self._currentType then
		logError("springTypeMismatch", nil, newType, self._currentType)
	end

	self._springPositions = unpackType(newValue, newType)
	self._currentValue = newValue
	SpringScheduler.add(self)
	updateAll(self)
end

--[[
	Sets the velocity of the internal springs, overwriting the existing velocity
	of this Spring. This doesn't affect position.

	If the type doesn't match the current type of the spring, an error will be
	thrown.
]]
function class:setVelocity(
	newValue: Types.Animatable
)
	local self = self :: InternalTypes.Spring<unknown>
	local newType = typeof(newValue)
	if newType ~= self._currentType then
		logError("springTypeMismatch", nil, newType, self._currentType)
	end

	self._springVelocities = unpackType(newValue, newType)
	SpringScheduler.add(self)
end

--[[
	Adds to the velocity of the internal springs, on top of the existing
	velocity of this Spring. This doesn't affect position.

	If the type doesn't match the current type of the spring, an error will be
	thrown.
]]
function class:addVelocity(
	deltaValue: Types.Animatable
)
	local self = self :: InternalTypes.Spring<unknown>
	local deltaType = typeof(deltaValue)
	if deltaType ~= self._currentType then
		logError("springTypeMismatch", nil, deltaType, self._currentType)
	end

	local springDeltas = unpackType(deltaValue, deltaType)
	for index, delta in ipairs(springDeltas) do
		self._springVelocities[index] += delta
	end
	SpringScheduler.add(self)
end

--[[
	Called when the goal state changes value, or when the speed or damping has
	changed.
]]
function class:update(): boolean
	local self = self :: InternalTypes.Spring<unknown>
	local goalValue = peek(self._goalState)

	-- figure out if this was a goal change or a speed/damping change
	if goalValue == self._goalValue then
		-- speed/damping change
		local damping = peek(self._damping)
		if typeof(damping) ~= "number" then
			logErrorNonFatal("mistypedSpringDamping", nil, typeof(damping))
		elseif damping < 0 then
			logErrorNonFatal("invalidSpringDamping", nil, damping)
		else
			self._currentDamping = damping
		end

		local speed = peek(self._speed)
		if typeof(speed) ~= "number" then
			logErrorNonFatal("mistypedSpringSpeed", nil, typeof(speed))
		elseif speed < 0 then
			logErrorNonFatal("invalidSpringSpeed", nil, speed)
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

--[[
	Returns the interior value of this state object.
]]
function class:_peek(): unknown
	local self = self :: InternalTypes.Spring<unknown>
	return self._currentValue
end

function class:get()
	logError("stateGetWasRemoved")
end

function class:destroy()
	local self = self :: InternalTypes.Spring<unknown>
	if self.scope == nil then
		logError("destroyedTwice", nil, "Spring")
	end
	SpringScheduler.remove(self)
	self.scope = nil
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
end

local function Spring<T>(
	scope: Types.Scope<unknown>,
	goalState: Types.StateObject<T>,
	speed: Types.CanBeState<number>?,
	damping: Types.CanBeState<number>?
): Types.Spring<T>
	if isState(scope) then
		logError("scopeMissing", nil, "Springs", "myScope:Spring(goalState, speed, damping)")
	end
	-- apply defaults for speed and damping
	if speed == nil then
		speed = 10
	end
	if damping == nil then
		damping = 1
	end

	local dependencySet: {[Types.Dependency]: unknown} = {[goalState] = true}
	if isState(speed) then
		local speed = speed :: Types.StateObject<number>
		dependencySet[speed] = true
	end
	if isState(damping) then
		local damping = damping :: Types.StateObject<number>
		dependencySet[damping] = true
	end

	local self = setmetatable({
		scope = scope,
		dependencySet = dependencySet,
		dependentSet = {},
		_speed = speed,
		_damping = damping,

		_goalState = goalState,
		_goalValue = nil,

		_currentType = nil,
		_currentValue = nil,
		_currentSpeed = peek(speed),
		_currentDamping = peek(damping),

		_springPositions = nil,
		_springGoals = nil,
		_springVelocities = nil,

		_lastSchedule = -math.huge,
		_startDisplacements = {},
		_startVelocities = {}
	}, CLASS_METATABLE)
	local self = (self :: any) :: InternalTypes.Spring<T>

	table.insert(scope, self)
	if goalState.scope == nil then
		logError("useAfterDestroy", nil, `The {goalState.kind} object`, `the Spring that is following it`)
	elseif whichLivesLonger(scope, self, goalState.scope, goalState) == "definitely-a" then
		logWarn("possiblyOutlives", `The {goalState.kind} object`, `the Spring that is following it`)
	end

	-- add this object to the goal state's dependent set
	goalState.dependentSet[self] = true
	self:update()

	return self
end

return Spring