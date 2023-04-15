-- TODO: type annotate this file

local function ExtendFriction(decayFactor)
	local invLogDecayFactor = 1 / math.log(decayFactor)
	return function(startDisplacement, startVelocity)
		startDisplacement = startDisplacement or 0
		startVelocity = startVelocity or 0
		local scaledStartVelocity = startVelocity * invLogDecayFactor
		return function(time)
			local decayExpNegTime = decayFactor ^ -time
			return
				startDisplacement + (1 - decayExpNegTime) * scaledStartVelocity,
				startVelocity * decayExpNegTime
		end
	end
end

return ExtendFriction