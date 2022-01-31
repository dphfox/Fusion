--!strict

--[[
	Manages batch updating of spring objects.
]]

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Types = require(Package.Types)
local packType = require(Package.Animation.packType)
local springCoefficients = require(Package.Animation.springCoefficients)
local updateAll = require(Package.Dependencies.updateAll)
local logError = require(Package.Logging.logError)

type Set<T> = {[T]: any}
type Spring = Types.Spring<any>

local SpringScheduler = {}

local WEAK_KEYS_METATABLE = {__mode = "k"}

-- when a spring has displacement and velocity below +/- epsilon, the spring
-- won't send updates
local MOVEMENT_EPSILON = 0.0001

local activeSprings: Set<Spring> = {}

--[[
	Adds a Spring to be updated every render step.
]]
function SpringScheduler.add(spring: Spring)
	local damping: number
	local speed: number

	if spring._dampingIsState then
		local state: PubTypes.StateObject<number> = spring._damping
		damping = state:get(false)
	else
		damping = spring._damping
	end

	if spring._speedIsState then
		local state: PubTypes.StateObject<number> = spring._speed
		speed = state:get(false)
	else
		speed = spring._speed
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
	spring._lastSchedule = os.clock()

	spring._startDisplacements = {}
	spring._startVelocities = {}

	for index, goal in ipairs(spring._springGoals) do
		local oldPosition = spring._springPositions[index]
		local oldVelocity = spring._springVelocities[index]

		local oldDisplacement = oldPosition - goal

		spring._startDisplacements[index] = oldDisplacement
		spring._startVelocities[index] = oldVelocity
	end

	activeSprings[spring] = true
end

--[[
	Removes a Spring from the scheduler.
]]
function SpringScheduler.remove(spring: Spring)
	activeSprings[spring] = nil
end

--[[
	Updates all Spring objects.
]]
local a = 0
local springsToUpdate: Set<Spring> = {}
local springsToSleep: Set<Spring> = {}

local function updateAllSprings()
	local now = os.clock()
	table.clear(springsToUpdate)
	table.clear(springsToSleep)
	for spring in pairs(activeSprings) do
		local posPosCoef, posVelCoef, velPosCoef, velVelCoef = springCoefficients(now - spring._lastSchedule, spring._lastDamping, spring._lastSpeed)
		local goals = spring._springGoals
		local startDisplacements = spring._startDisplacements
		local startVelocities = spring._startVelocities
		local positions = spring._springPositions
		local velocities = spring._springVelocities

		local isMoving = false

		for index, goal in ipairs(goals) do
			local oldPosition = startDisplacements[index]
			local oldVelocity = startVelocities[index]

			local oldDisplacement = oldPosition - goal

			local newDisplacement = oldDisplacement * posPosCoef + oldVelocity * posVelCoef
			local newVelocity = oldDisplacement * velPosCoef + oldVelocity * velVelCoef

			if not isMoving and (math.abs(newDisplacement) > MOVEMENT_EPSILON or math.abs(newVelocity) > MOVEMENT_EPSILON) then
				isMoving = true
			end

			positions[index] = newDisplacement + goal
			velocities[index] = newVelocity
		end

		-- if the spring moved a significant distance, update its
		-- current value, otherwise stop animating
		if isMoving then
			springsToUpdate[spring] = true
		else
			springsToSleep[spring] = true
		end
	end

	for spring in pairs(springsToSleep) do
		SpringScheduler.remove(spring)
	end

	for spring in pairs(springsToUpdate) do
		spring._currentValue = packType(spring._springPositions, spring._currentType)
		updateAll(spring)
	end
	print(a, math.ceil((os.clock() - now) * 1000 * 100) / 100)
	a += 1
end

RunService:BindToRenderStep(
	"__FusionSpringScheduler",
	Enum.RenderPriority.First.Value,
	updateAllSprings
)

return SpringScheduler