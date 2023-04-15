-- TODO: type annotate this file

local function SetVelocity(velocity)
	return function(startDisplacement)
		startDisplacement = startDisplacement or 0
		return function(time)
			return
			startDisplacement + time * velocity,
				velocity
		end
	end
end

return SetVelocity