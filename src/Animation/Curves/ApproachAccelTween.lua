-- TODO: type annotate this file

local function ApproachAccelTween(maxAcceleration)
	-- TODO: consult acceltween docs, figure all this out

	return function(startDisplacement, startVelocity)
		startDisplacement = startDisplacement or 0
		startVelocity = startVelocity or 0
		return function(time)
			-- TODO: consult acceltween docs, figure all this out
			return 0
		end
	end
end

return ApproachAccelTween