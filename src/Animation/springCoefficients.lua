--!strict

--[[
	Returns a 2x2 matrix of coefficients for a given damping ratio, speed and
	time step. These coefficients can then be multiplied with the position and
	velocity of an existing spring to find the new position and velocity values.

	Specifically, this function returns four numbers -  posPos, posVel, velPos,
	and velVel, in that order - which can be applied to position and velocity
	like so:

	local newPosition = oldPosition * posPos + oldVelocity * posVel
	local newVelocity = oldPosition * velPos + oldVelocity * velVel

	If a large number of springs with identical damping ratios and speeds are
	being updated with the same time step, then these coefficients can be used
	to update all of them at once.

	This function assumes the damping ratio, speed and time step are all >= 0,
	with the expectation that these values have been verified beforehand.

	Special thanks to AxisAngle for helping to reduce some floating point errors
	for underdamped springs.
]]

local function springCoefficients(time: number, damping: number, speed: number): (number, number, number, number)
	-- if time or speed is 0, then the spring won't move, so an identity
	-- matrix can be returned early
	if time == 0 or speed == 0 then
		return
			1, 0,
			0, 1
	end

	if damping > 1 then
		-- overdamped spring

		-- solutions to the characteristic equation
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

		local posPosCoef = (expZ2*z1 - expZ1*z2) * scaledInvAlpha
		local posVelCoef = (expZ1 - expZ2) * scaledInvAlpha / speed

		local velPosCoef = (expZ2 - expZ1) * scaledInvAlpha * speed
		local velVelCoef = (expZ1*z1 - expZ2*z2) * scaledInvAlpha

		return
			posPosCoef, posVelCoef,
			velPosCoef, velVelCoef

	elseif damping == 1 then
		-- critically damped spring

		-- x[t] -> x0(e^-tω)(1+tω) + v0(e^-tω)t
		-- v[t] -> x0(t ω^2)(-e^-tω) + v0(1 - tω)(e^-tω)

		local scaledTime = time * speed
		local expTerm = math.exp(-scaledTime)

		local posPosCoef = expTerm * (1 + scaledTime)
		local posVelCoef = expTerm * time

		local velPosCoef = expTerm * (-scaledTime*speed)
		local velVelCoef = expTerm * (1 - scaledTime)

		return
			posPosCoef, posVelCoef,
			velPosCoef, velVelCoef

	else
		-- underdamped spring

		-- factored out of the solutions to the characteristic equation, to make
		-- the math cleaner
		-- α = Sqrt[1 - ζ^2]

		-- x[t] -> x0(e^-tζω)(α Cos[tα] + ζω Sin[tα])/α
		--       + v0(e^-tζω)(Sin[tα])/α

		-- v[t] -> x0(-e^-tζω)(α^2 + ζ^2 ω^2)(Sin[tα])/α
		--       + v0(e^-tζω)(α Cos[tα] - ζω Sin[tα])/α

		local alpha = math.sqrt(1 - damping^2)
		local invAlpha = 1 / alpha
		local alphaTime = alpha * time
		local expTerm = math.exp(-time*damping*speed)
		local sinTerm = expTerm * math.sin(alphaTime)
		local cosTerm = expTerm * math.cos(alphaTime)
		local sinInvAlpha = sinTerm*invAlpha
		local sinInvAlphaDamp = sinInvAlpha*damping

		local posPosCoef = sinInvAlphaDamp + cosTerm
		local posVelCoef = sinInvAlpha / speed

		local velPosCoef = (sinInvAlphaDamp*damping + sinTerm*alpha) * -speed
		local velVelCoef = cosTerm - sinInvAlphaDamp

		return
			posPosCoef, posVelCoef,
			velPosCoef, velVelCoef
	end
end

return springCoefficients