-- TODO: type annotate this file

local function ExtendAcceleration(startDisplacement, startVelocity, startAcceleration)
	startDisplacement = startDisplacement or 0
	startVelocity = startVelocity or 0
	startAcceleration = startAcceleration or 0
	return function(time)
		return
			startDisplacement + time * startVelocity + time^2 * startAcceleration,
			startVelocity + time * startAcceleration,
			startAcceleration
	end
end

return ExtendAcceleration