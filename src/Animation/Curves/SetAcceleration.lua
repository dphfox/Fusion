-- TODO: type annotate this file

local function SetAcceleration(acceleration)
	return function(startDisplacement, startVelocity)
		startDisplacement = startDisplacement or 0
		startVelocity = startVelocity or 0
		return function(time)
			return
				startDisplacement + time * startVelocity + time^2 * acceleration,
				startVelocity + time * acceleration,
				acceleration
		end
	end
end

return SetAcceleration