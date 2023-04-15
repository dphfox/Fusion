-- TODO: type annotate this file

local function ExtendVelocity(startDisplacement, startVelocity)
	startDisplacement = startDisplacement or 0
	startVelocity = startVelocity or 0
	return function(time)
		return
			startDisplacement + time * startVelocity,
			startVelocity
	end
end

return ExtendVelocity