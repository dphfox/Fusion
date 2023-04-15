-- TODO: type annotate this file

local function ApproachBezier(x1, y1, x2, y2, duration)
	-- TODO: calculate polynomial expansion & useful terms using control points

	return function(startDisplacement)
		startDisplacement = startDisplacement or 0
		return function(time)
			local scaledTime = time / duration

			if scaledTime <= 0 then -- before bezier started
				return startDisplacement
			elseif scaledTime >= 1 then -- after bezier ended
				return 0
			else -- during bezier motion
				-- TODO: derive t-value from scaled time
				-- TODO: use t-value to compute position and velocity
				return 0
			end
		end
	end
end

return ApproachBezier