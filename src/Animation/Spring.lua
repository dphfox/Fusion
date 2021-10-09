--[[
	Constructs a new computed state object, which follows the value of another
	state object using a spring simulation.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logError = require(Package.Logging.logError)
local unpackType = require(Package.Animation.unpackType)
local SpringScheduler = require(Package.Animation.SpringScheduler)
local useDependency = require(Package.Dependencies.useDependency)
local initDependency = require(Package.Dependencies.initDependency)
local updateAll = require(Package.Dependencies.updateAll)

local class = {}

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}

local ENABLE_PARAM_SETTERS = false

--[[
	Returns the current value of this Spring object.
	The object will be registered as a dependency unless `asDependency` is false.
]]
function class:get(asDependency: boolean?)
	if asDependency ~= false then
		useDependency(self)
	end
	return self._currentValue
end

--[[
	Called when the goal state changes value, or when the speed or damping has
	changed.

	For speed/damping changes:

	The spring will be updated in the spring scheduler to match the new speed
	and damping values. Returns false, as this has no immediate impact on the
	current value of the Spring object.

	For goal changes:

	If the new goal can be animated to, the equilibrium point of the internal
	springs will be moved, but the springs themselves stay in place.
	Returns false, as this has no immediate impact on the current value of the
	Spring object.

	If the new goal can't be animated to (different types/non-animatable type),
	then the springs will be instantly moved to the goal value. Returns true, as
	the current value of the Spring object will jump directly to the goal.
]]
function class:update()
	local goalValue = self._goalState:get(false)

	-- figure out if this was a goal change or a speed/damping change
	if goalValue == self._goalValue then
		-- speed/damping change - re-add to spring scheduler to assign to a new
		-- bucket

		SpringScheduler.remove(self)
		SpringScheduler.add(self)
		return false

	else
		-- goal change - reconfigure spring to target new goal
		local oldType = self._currentType
		local newType = typeof(goalValue)

		self._goalValue = goalValue
		self._currentType = newType

		local springGoals = unpackType(goalValue, newType)
		local numSprings = #springGoals

		self._springGoals = springGoals

		if newType ~= oldType then
			-- if the type changed, we need to set the position and velocity
			local springPositions = table.create(numSprings, 0)
			local springVelocities = table.create(numSprings, 0)

			for index, springGoal in ipairs(springGoals) do
				springPositions[index] = springGoal
			end

			self._springPositions = springPositions
			self._springVelocities = springVelocities
			self._currentValue = self._goalValue

			SpringScheduler.remove(self)
			return true

		elseif numSprings == 0 then
			-- if the type hasn't changed, but isn't animatable, just change the
			-- current value
			self._currentValue = self._goalValue

			SpringScheduler.remove(self)
			return true

		else
			-- types match, and is animatable, so just add to the spring
			-- scheduler and let it animate to the goal!
			SpringScheduler.add(self)
			return false
		end
	end
end

if ENABLE_PARAM_SETTERS then
	--[[
		Sets the position of the internal springs, meaning the value of this
		Spring will jump to the given value. This doesn't affect velocity.

		If the type doesn't match the current type of the spring, an error will be
		thrown.
	]]
	function class:setPosition(newValue: Types.Animatable)
		local newType = typeof(newValue)
		if newType ~= self._currentType then
			logError("springTypeMismatch", nil, newType, self._currentType)
		end

		self._springPositions = unpackType(newValue, newType)
		self._currentValue = newValue

		updateAll(self)

		SpringScheduler.add(self)
	end

	--[[
		Sets the velocity of the internal springs, overwriting the existing velocity
		of this Spring. This doesn't affect position.

		If the type doesn't match the current type of the spring, an error will be
		thrown.
	]]
	function class:setVelocity(newValue: Types.Animatable)
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
	function class:addVelocity(deltaValue: Types.Animatable)
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

end

local function Spring(
	goalState: Types.State<Types.Animatable>,
	speed: Types.StateOrValue<number>?,
	damping: Types.StateOrValue<number>?
)
	-- apply defaults for speed and damping
	if speed == nil then
		speed = 10
	end

	if damping == nil then
		damping = 1
	end

	local dependencySet = {[goalState] = true}
	local speedIsState = typeof(speed) == "table" and speed.type == "State"
	local dampingIsState = typeof(damping) == "table" and damping.type == "State"

	if speedIsState then
		dependencySet[speed] = true
	end

	if dampingIsState then
		dependencySet[damping] = true
	end

	local self = setmetatable({
		type = "State",
		kind = "Spring",
		dependencySet = dependencySet,
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_speed = speed,
		_speedIsState = speedIsState,
		_lastSpeed = nil,
		_damping = damping,
		_dampingIsState = dampingIsState,
		_lastDamping = nil,

		_goalState = goalState,
		_goalValue = nil,

		_currentType = nil,
		_currentValue = nil,

		_springPositions = nil,
		_springGoals = nil,
		_springVelocities = nil
	}, CLASS_METATABLE)

	initDependency(self)
	-- add this object to the goal state's dependent set
	goalState.dependentSet[self] = true
	self:update()

	return self
end

return Spring