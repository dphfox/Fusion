--[[
	Continues the motion defined by the initial velocity and acceleration.
]]

-- TODO: type annotate this file

local function Extrapolate(initialValues)
	local dimension = #initialValues[1]
	local zero = table.create(dimension, 0)
	local initialDisplacement = initialValues[1]
	local initialVelocity = initialValues[2] or zero
	local initialAcceleration = initialValues[3] or zero
	return {
		-- displacement
		function(time)
			local displacement = table.create(dimension, 0)
			for index in displacement do
				displacement[index] =
					initialDisplacement[index] +
					time * initialVelocity[index] +
					time^2 * initialAcceleration[index]
			end
			return displacement
		end,
		-- velocity
		function(time)
			local velocity = table.create(dimension, 0)
			for index in velocity do
				velocity[index] =
					initialVelocity[index] +
					time * initialAcceleration[index]
			end
			return velocity
		end,
		-- acceleration
		function(time)
			return initialAcceleration
		end
	}
end

return Extrapolate