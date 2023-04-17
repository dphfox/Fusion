--[[
	Returns to zero displacement based on a cubic Bezier curve.
]]

-- TODO: type annotate this file

local function Bezier(x1, y1, x2, y2, duration)
	-- TODO: calculate polynomial expansion & useful terms using control points
	return function(initialValues)
		local dimension = #initialValues[1]
		local zero = table.create(dimension, 0)
		local initialDisplacement = initialValues[1]

		return {
			-- displacement
			function(time)
				local scaledTime = time / duration
				if scaledTime <= 0 then -- before bezier started
					return initialDisplacement
				elseif scaledTime >= 1 then -- after bezier ended
					return zero
				else -- during bezier motion
					-- TODO: derive t-value from scaled time
					-- TODO: use t-value to compute position and velocity
					return zero
				end
			end,
			-- velocity
			function(time)
				local scaledTime = time / duration
				if scaledTime <= 0 then -- before bezier started
					return zero
				elseif scaledTime >= 1 then -- after bezier ended
					return zero
				else -- during bezier motion
					-- TODO: derive t-value from scaled time
					-- TODO: use t-value to compute position and velocity
					return zero
				end
			end
		}
	end
end

return Bezier