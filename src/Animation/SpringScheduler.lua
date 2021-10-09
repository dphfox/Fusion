--[[
	Manages batch updating of spring objects.
]]

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent
local Types = require(Package.Types)
local packType = require(Package.Animation.packType)
local springCoefficients = require(Package.Animation.springCoefficients)
local updateAll = require(Package.Dependencies.updateAll)
local logError = require(Package.Logging.logError)

local SpringScheduler = {}

type Spring = {
	_speed: number,
	_damping: number,

	_springPositions: {number},
	_springGoals: {number},
	_springVelocities: {number}
}

local WEAK_KEYS_METATABLE = {__mode = "k"}

-- when a spring has displacement and velocity below +/- epsilon, the spring
-- won't send updates
local MOVEMENT_EPSILON = 0.0001

-- organises springs by speed and damping, for batch processing
local springBuckets: {[number]: {[number]: Types.Set<Spring>}} = {}

--[[
	Adds a Spring to be updated every render step.
]]
function SpringScheduler.add(spring: Spring)
	local damping = spring._damping
	local speed = spring._speed

	if spring._dampingIsState then
		damping = damping:get(false)
	end
	if spring._speedIsState then
		speed = speed:get(false)
	end

	if typeof(damping) ~= "number" then
		logError("mistypedSpringDamping", nil, typeof(damping))
	elseif damping < 0 then
		logError("invalidSpringDamping", nil, damping)
	end

	if typeof(speed) ~= "number" then
		logError("mistypedSpringSpeed", nil, typeof(speed))
	elseif speed < 0 then
		logError("invalidSpringSpeed", nil, speed)
	end

	spring._lastDamping = damping
	spring._lastSpeed = speed

	local dampingBucket = springBuckets[damping]

	if dampingBucket == nil then
		springBuckets[damping] = {
			[speed] = setmetatable({[spring] = true}, WEAK_KEYS_METATABLE)
		}
		return
	end

	local speedBucket = dampingBucket[speed]

	if speedBucket == nil then
		dampingBucket[speed] = setmetatable({[spring] = true}, WEAK_KEYS_METATABLE)
		return
	end

	speedBucket[spring] = true
end

--[[
	Removes a Spring from the scheduler.
]]
function SpringScheduler.remove(spring: Spring)
	local damping = spring._lastDamping
	local speed = spring._lastSpeed

	local dampingBucket = springBuckets[damping]

	if dampingBucket == nil then
		return
	end

	local speedBucket = dampingBucket[speed]

	if speedBucket == nil then
		return
	end

	speedBucket[spring] = nil
end

--[[
	Updates all Spring objects.
]]
local function updateAllSprings(timeStep: number)
	for damping, dampingBucket in pairs(springBuckets) do
		for speed, speedBucket in pairs(dampingBucket) do
			local posPosCoef, posVelCoef, velPosCoef, velVelCoef = springCoefficients(timeStep, damping, speed)

			for spring in pairs(speedBucket) do
				local goals = spring._springGoals
				local positions = spring._springPositions
				local velocities = spring._springVelocities

				local isMoving = false

				for index, goal in ipairs(goals) do
					local oldPosition = positions[index]
					local oldVelocity = velocities[index]

					local oldDisplacement = oldPosition - goal

					local newDisplacement = oldDisplacement * posPosCoef + oldVelocity * posVelCoef
					local newVelocity = oldDisplacement * velPosCoef + oldVelocity * velVelCoef

					if
						math.abs(newDisplacement) > MOVEMENT_EPSILON or
						math.abs(newVelocity) > MOVEMENT_EPSILON
					then
						isMoving = true
					end

					positions[index] = newDisplacement + goal
					velocities[index] = newVelocity
				end

				-- if the spring moved a significant distance, update its
				-- current value, otherwise stop animating
				if isMoving then
					spring._currentValue = packType(positions, spring._currentType)
					updateAll(spring)
				else
					SpringScheduler.remove(spring)
				end
			end
		end
	end
end

RunService:BindToRenderStep(
	"__FusionSpringScheduler",
	Enum.RenderPriority.First.Value,
	updateAllSprings
)

return SpringScheduler