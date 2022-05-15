--!strict

--[[
	Returns a 2x2 matrix of coefficients for a given time, damping and speed.
	Specifically, this returns four coefficients - posPos, posVel, velPos, and
	velVel - which can be multiplied with position and velocity like so:

	local newPosition = oldPosition * posPos + oldVelocity * posVel
	local newVelocity = oldPosition * velPos + oldVelocity * velVel

	Special thanks to AxisAngle for helping to improve numerical precision.
]]

local function springCoefficients(time: number, damping: number, speed: number): (number, number, number, number)
	-- if time or speed is 0, then the spring won't move
	if time == 0 or speed == 0 then
		return 1, 0, 0, 1
	end
	local posPos, posVel, velPos, velVel

	if damping > 1 then
		-- overdamped spring
		-- solution to the characteristic equation:
		-- z = -ζω ± Sqrt[ζ^2 - 1] ω
		-- x[t] -> x0(e^(t z2) z1 - e^(t z1) z2)/(z1 - z2)
		--		 + v0(e^(t z1) - e^(t z2))/(z1 - z2)
		-- v[t] -> x0(z1 z2(-e^(t z1) + e^(t z2)))/(z1 - z2)
		--		 + v0(z1 e^(t z1) - z2 e^(t z2))/(z1 - z2)

		local scaledTime = time * speed
		local alpha = math.sqrt(damping^2 - 1)
		local scaledInvAlpha = -0.5 / alpha
		local z1 = -alpha - damping
		local z2 = 1 / z1
		local expZ1 = math.exp(scaledTime * z1)
		local expZ2 = math.exp(scaledTime * z2)

		posPos = (expZ2*z1 - expZ1*z2) * scaledInvAlpha
		posVel = (expZ1 - expZ2) * scaledInvAlpha / speed
		velPos = (expZ2 - expZ1) * scaledInvAlpha * speed
		velVel = (expZ1*z1 - expZ2*z2) * scaledInvAlpha

	elseif damping == 1 then
		-- critically damped spring
		-- x[t] -> x0(e^-tω)(1+tω) + v0(e^-tω)t
		-- v[t] -> x0(t ω^2)(-e^-tω) + v0(1 - tω)(e^-tω)

		local scaledTime = time * speed
		local expTerm = math.exp(-scaledTime)

		posPos = expTerm * (1 + scaledTime)
		posVel = expTerm * time
		velPos = expTerm * (-scaledTime*speed)
		velVel = expTerm * (1 - scaledTime)

	else
		-- underdamped spring
		-- factored out of the solutions to the characteristic equation:
		-- α = Sqrt[1 - ζ^2]
		-- x[t] -> x0(e^-tζω)(α Cos[tα] + ζω Sin[tα])/α
		--       + v0(e^-tζω)(Sin[tα])/α
		-- v[t] -> x0(-e^-tζω)(α^2 + ζ^2 ω^2)(Sin[tα])/α
		--       + v0(e^-tζω)(α Cos[tα] - ζω Sin[tα])/α

		local scaledTime = time * speed
		local alpha = math.sqrt(1 - damping^2)
		local invAlpha = 1 / alpha
		local alphaTime = alpha * scaledTime
		local expTerm = math.exp(-scaledTime*damping)
		local sinTerm = expTerm * math.sin(alphaTime)
		local cosTerm = expTerm * math.cos(alphaTime)
		local sinInvAlpha = sinTerm*invAlpha
		local sinInvAlphaDamp = sinInvAlpha*damping

		posPos = sinInvAlphaDamp + cosTerm
		posVel = sinInvAlpha
		velPos = -(sinInvAlphaDamp*damping + sinTerm*alpha)
		velVel = cosTerm - sinInvAlphaDamp
	end

	return posPos, posVel, velPos, velVel
end

return springCoefficients