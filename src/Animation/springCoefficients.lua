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

		-- x[t] -> x0(e^(t z2) z1 - e^(t z1) z2)/(z1 - z2)
		--		 + v0(e^(t z1) - e^(t z2))/(z1 - z2)

		-- v[t] -> x0(z1 z2(-e^(t z1) + e^(t z2)))/(z1 - z2)
		--		 + v0(z1 e^(t z1) - z2 e^(t z2))/(z1 - z2)

		local timeStepSpeed = timeStep * speed
		local zRoot = math.sqrt(damping^2 - 1)
		local z1 = -zRoot - damping
		local z2 = 1 / z1
		local z1Exp = math.exp(timeStepSpeed * z1)
		local z2Exp = math.exp(timeStepSpeed * z2)
		local zDivideSpeed = -0.5 / zRoot

		local posPosCoef = (z2Exp*z1 - z1Exp*z2) * zDivideSpeed
		local posVelCoef = (z1Exp - z2Exp) * zDivideSpeed / speed

		local velPosCoef = (z2Exp - z1Exp) * zDivideSpeed * speed
		local velVelCoef = (z1Exp*z1 - z2Exp*z2) * zDivideSpeed

		return
			posPosCoef, posVelCoef,
			velPosCoef, velVelCoef

	elseif damping == 1 then
		-- critically damped spring

		-- x[t] -> x0(e^-tω)(1+tω) + v0(e^-tω)t
		-- v[t] -> x0(t ω^2)(-e^-tω) + v0(1 - tω)(e^-tω)

		local timeStepSpeed = timeStep * speed
		local negSpeedExp = math.exp(-timeStepSpeed)

		local posPosCoef = negSpeedExp * (1 + timeStepSpeed)
		local posVelCoef = negSpeedExp * timeStep

		local velPosCoef = negSpeedExp * (-timeStepSpeed*speed)
		local velVelCoef = negSpeedExp * (1 - timeStepSpeed)

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
		local expTerm = math.exp(-timeStep*damping*speed)
		local sinTerm = expTerm * math.sin(timeStep*alpha)
		local cosTerm = expTerm * math.cos(timeStep*alpha)
		local sinInvAlpha = sinTerm*invAlpha
		local sinDampInvAlpha = sinInvAlpha*damping

		local posPosCoef = sinDampInvAlpha + cosTerm
		local posVelCoef = sinInvAlpha / speed

		local velPosCoef = (sinDampInvAlpha*damping + sinTerm*alpha) * -speed
		local velVelCoef = cosTerm - sinDampInvAlpha

		return
			posPosCoef, posVelCoef,
			velPosCoef, velVelCoef
	end
end

return springCoefficients