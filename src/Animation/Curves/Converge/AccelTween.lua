--[[
	Returns to zero displacement with maximum acceleration.
]]

-- TODO: type annotate this file

local function AccelTween(maxAcceleration)
	-- TODO: consult acceltween docs, figure all this out
	return function(initialValues)
		local dimension = #initialValues[1]
		local zero = table.create(dimension, 0)
		local initialDisplacement = initialValues[1]
		local initialVelocity = initialValues[2] or zero

		return {
			-- displacement
			function(time)
				-- TODO: consult acceltween docs, figure all this out
				return initialValues[1]
			end,
			-- velocity
			function(time)
				-- TODO: consult acceltween docs, figure all this out
				return zero
			end
		}
	end
end

return AccelTween