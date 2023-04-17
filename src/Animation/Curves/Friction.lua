--[[
	Moves while decaying velocity to zero.
]]

-- TODO: type annotate this file

local function Friction(decayFactor)
	local invLogDecayFactor = 1 / math.log(decayFactor)
	return function(initialValues)
		local dimension = #initialValues[1]
		local zero = table.create(dimension, 0)
		local initialDisplacement = initialValues[1]
		local initialVelocity = initialValues[2] or zero
		return {
			-- displacement
			function(time)
				local velFactor = (1 - decayFactor ^ -time) * invLogDecayFactor
				local displacement = table.create(dimension, 0)
				for index in displacement do
					displacement[index] = initialDisplacement[index] + velFactor * initialVelocity[index]
				end
				return displacement
			end,
			-- velocity
			function(time)
				local velFactor = decayFactor ^ -time
				local velocity = table.create(dimension, 0)
				for index in velocity do
					velocity[index] = initialVelocity[index] * velFactor
				end
				return velocity
			end
		}
	end
end

return Friction