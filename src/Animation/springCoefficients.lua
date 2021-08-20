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
]]

local function springCoefficients(timeStep: number, damping: number, speed: number): (number, number, number, number)
	-- if time step or speed is 0, then the spring won't move, so an identity
	-- matrix can be returned early
	if timeStep == 0 or speed == 0 then
		return
			1, 0,
			0, 1
	end

	if damping > 1 then
		-- overdamped spring

		-- solutions to the characteristic equation
		-- z = -ζω ± Sqrt[ζ^2 - 1] ω

		local zRoot = math.sqrt(damping^2 - 1)

		local z1 = (-zRoot - damping)*speed
		local z2 = (zRoot - damping)*speed

		-- x[t] -> x0(e^(t z2) z1 - e^(t z1) z2)/(z1 - z2)
		--		 + v0(e^(t z1) - e^(t z2))/(z1 - z2)

		local zDivide = 1/(z1 - z2)

		local z1Exp = math.exp(timeStep * z1)
		local z2Exp = math.exp(timeStep * z2)

		local posPosCoef = (z2Exp * z1 - z1Exp * z2) * zDivide
		local posVelCoef = (z1Exp - z2Exp) * zDivide

		-- v[t] -> x0(z1 z2(-e^(t z1) + e^(t z2)))/(z1 - z2)
		--		 + v0(z1 e^(t z1) - z2 e^(t z2))/(z1 - z2)

		local velPosCoef = z1*z2 * (-z1Exp + z2Exp) * zDivide
		local velVelCoef = (z1*z1Exp - z2*z2Exp) * zDivide

		return
			posPosCoef, posVelCoef,
			velPosCoef, velVelCoef

	elseif damping == 1 then
		-- critically damped spring

		-- x[t] -> x0(e^-tω)(1+tω) + v0(e^-tω)t

		local timeStepSpeed = timeStep * speed
		local negSpeedExp = math.exp(-timeStepSpeed)

		local posPosCoef = negSpeedExp * (1 + timeStepSpeed)
		local posVelCoef = negSpeedExp * timeStep

		-- v[t] -> x0(t ω^2)(-e^-tω) + v0(1 - tω)(e^-tω)

		local velPosCoef = -negSpeedExp * (timeStep * speed*speed)
		local velVelCoef = negSpeedExp * (1 - timeStepSpeed)

		return
			posPosCoef, posVelCoef,
			velPosCoef, velVelCoef

	else
		-- underdamped spring

		-- factored out of the solutions to the characteristic equation, to make
		-- the math cleaner

		local alpha = math.sqrt(1 - damping^2) * speed

		-- x[t] -> x0(e^-tζω)(α Cos[tα] + ζω Sin[tα])/α
		--       + v0(e^-tζω)(Sin[tα])/α

		local negDampSpeedExp = math.exp(-timeStep * damping * speed)

		local sinAlpha = math.sin(timeStep*alpha)
		local alphaCosAlpha = alpha * math.cos(timeStep*alpha)
		local dampSpeedSinAlpha = damping*speed*sinAlpha

		local invAlpha = 1 / alpha

		local posPosCoef = negDampSpeedExp * (alphaCosAlpha + dampSpeedSinAlpha) * invAlpha
		local posVelCoef = negDampSpeedExp * sinAlpha * invAlpha

		-- v[t] -> x0(-e^-tζω)(α^2 + ζ^2 ω^2)(Sin[tα])/α
		--       + v0(e^-tζω)(α Cos[tα] - ζω Sin[tα])/α

		local velPosCoef = -negDampSpeedExp * (alpha*alpha + damping*damping * speed*speed) * sinAlpha * invAlpha
		local velVelCoef = negDampSpeedExp * (alphaCosAlpha - dampSpeedSinAlpha) * invAlpha

		return
			posPosCoef, posVelCoef,
			velPosCoef, velVelCoef
	end
end

return springCoefficients