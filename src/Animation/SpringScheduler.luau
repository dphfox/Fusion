--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Manages batch updating of spring objects.
]]

local Package = script.Parent.Parent
local InternalTypes = require(Package.InternalTypes)
local External = require(Package.External)
local packType = require(Package.Animation.packType)
local springCoefficients = require(Package.Animation.springCoefficients)
local updateAll = require(Package.State.updateAll)

type Set<T> = {[T]: unknown}

local SpringScheduler = {}

local EPSILON = 0.0001
local activeSprings: Set<InternalTypes.Spring<unknown>> = {}
local lastUpdateTime = External.lastUpdateStep()

function SpringScheduler.add(
	spring: InternalTypes.Spring<unknown>
)
	-- we don't necessarily want to use the most accurate time - here we snap to
	-- the last update time so that springs started within the same frame have
	-- identical time steps
	spring._lastSchedule = lastUpdateTime
	table.clear(spring._startDisplacements)
	table.clear(spring._startVelocities)
	for index, goal in ipairs(spring._springGoals) do
		spring._startDisplacements[index] = spring._springPositions[index] - goal
		spring._startVelocities[index] = spring._springVelocities[index]
	end

	activeSprings[spring] = true
end

function SpringScheduler.remove(
	spring: InternalTypes.Spring<unknown>
)
	activeSprings[spring] = nil
end

local function updateAllSprings(
	now: number
)
	local springsToSleep: Set<InternalTypes.Spring<unknown>> = {}
	lastUpdateTime = now

	for spring in pairs(activeSprings) do
		local posPos, posVel, velPos, velVel = springCoefficients(
			lastUpdateTime - spring._lastSchedule,
			spring._currentDamping,
			spring._currentSpeed
		)

		local positions = spring._springPositions
		local velocities = spring._springVelocities
		local startDisplacements = spring._startDisplacements
		local startVelocities = spring._startVelocities
		local isMoving = false

		for index, goal in ipairs(spring._springGoals) do
			if goal ~= goal then
				External.logWarn("springNanGoal")
				continue
			end

			local oldDisplacement = startDisplacements[index]
			local oldVelocity = startVelocities[index]
			local newDisplacement = oldDisplacement * posPos + oldVelocity * posVel
			local newVelocity = oldDisplacement * velPos + oldVelocity * velVel

			if newDisplacement ~= newDisplacement or newVelocity ~= newVelocity then
				External.logWarn("springNanMotion")
				newDisplacement = 0
				newVelocity = 0
			end

			if math.abs(newDisplacement) > EPSILON or math.abs(newVelocity) > EPSILON then
				isMoving = true
			end

			positions[index] = newDisplacement + goal
			velocities[index] = newVelocity
		end

		if not isMoving then
			springsToSleep[spring] = true
		end
	end

	for spring in pairs(springsToSleep) do
		activeSprings[spring] = nil
		-- Guarantee that springs reach exact goals, since mathematically they only approach it infinitely
		spring._currentValue = packType(spring._springGoals, spring._currentType)
		updateAll(spring)
	end

	for spring in pairs(activeSprings) do
		spring._currentValue = packType(spring._springPositions, spring._currentType)
		updateAll(spring)
	end
end

External.bindToUpdateStep(updateAllSprings)

return SpringScheduler
