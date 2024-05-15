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
local updateAll = require(Package.State.updateAll)
local isState = require(Package.State.isState)
local peek = require(Package.State.peek)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

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
		External.logError("springTypeMismatch", nil, newType, self._currentType)
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
		External.logError("springTypeMismatch", nil, newType, self._currentType)
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
		External.logError("springTypeMismatch", nil, deltaType, self._currentType)
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

--[[
	Returns the interior value of this state object.
]]
function class:_peek(): unknown
	local self = self :: InternalTypes.Spring<unknown>
	return self._currentValue
end

function class:get()
	External.logError("stateGetWasRemoved")
end

local function Spring<T>(
	scope: Types.Scope<unknown>,
	goal: Types.UsedAs<T>,
	speed: Types.UsedAs<number>?,
	damping: Types.UsedAs<number>?
): Types.Spring<T>
	if typeof(scope) ~= "table" or isState(scope) then
		External.logError("scopeMissing", nil, "Springs", "myScope:Spring(goalState, speed, damping)")
	end
	-- apply defaults for speed and damping
	if speed == nil then
		speed = 10
	end
	if damping == nil then
		damping = 1
	end

	local dependencySet: {[Types.Dependency]: unknown} = {}
	local goalIsState = isState(goal)
	if goalIsState then
		local goal = goal :: Types.StateObject<T>
		dependencySet[goal] = true
	end
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

		_goal = goal,
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

	local destroy = function()
		SpringScheduler.remove(self :: any)
		self.scope = nil
		for dependency in pairs(self.dependencySet) do
			dependency.dependentSet[self] = nil
		end
	end
	self.oldestTask = destroy
	table.insert(scope, destroy)
	
	if goalIsState then
		local goal = goal :: Types.StateObject<T>
		if goal.scope == nil then
			External.logError("useAfterDestroy", nil, `The {goal.kind} object`, `the Spring that is following it`)
		elseif whichLivesLonger(scope, self.oldestTask, goal.scope, goal.oldestTask) == "definitely-a" then
			External.logWarn("possiblyOutlives", `The {goal.kind} object`, `the Spring that is following it`)
		end
		-- add this object to the goal state's dependent set
		goal.dependentSet[self] = true
	end

	self:update()

	return self
end

return Spring