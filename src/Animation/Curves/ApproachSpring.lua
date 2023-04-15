-- TODO: type annotate this file

local Package = script.Parent.Parent
local springCoefficients = require(Package.springCoefficients)

local function ApproachSpring(speed, damping)
	speed = speed or 10
	damping = damping or 1
	return function(startDisplacement, startVelocity)
		startDisplacement = startDisplacement or 0
		startVelocity = startVelocity or 0
		startVelocity /= speed
		return function(time)
			local posPos, posVel, velPos, velVel = springCoefficients(time, speed, damping)
			local displacement = startDisplacement * posPos - startVelocity * posVel
			local velocity = startDisplacement * velPos - startVelocity * velVel
			return
				displacement,
				-velocity * speed
		end
	end
end

return ApproachSpring