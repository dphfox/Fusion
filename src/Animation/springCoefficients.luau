--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Returns a 2x2 matrix of coefficients for a given time, damping and angular
	frequency (aka 'speed').
	
	Specifically, this returns four coefficients - posPos, posVel, velPos, and
	velVel - which can be multiplied with position and velocity like so:

	local newPosition = oldPosition * posPos + oldVelocity * posVel
	local newVelocity = oldPosition * velPos + oldVelocity * velVel

	For speed = 1 and damping = 0, the result is a simple harmonic oscillator
	with a period of tau.

	Special thanks to AxisAngle for helping to improve numerical precision.
]]

local function springCoefficients(
	time: number,
	damping: number,
	speed: number
): (number, number, number, number)
	-- if time or speed is 0, then the spring won't move
	if time == 0 or speed == 0 then
		return 1, 0, 0, 1
	end
	local posPos, posVel, velPos, velVel

	if damping > 1 then
		-- overdamped spring

		local alpha = math.sqrt(damping^2 - 1)
		local negHalf_over_alpha_speed = -0.5 / (alpha * speed)
		local z1 = speed * (alpha + damping) * -1
		local z2 = speed * (alpha - damping)
		local exp1 = math.exp(time * z1)
		local exp2 = math.exp(time * z2)

		posPos = (exp2 * z1 - exp1 * z2) * negHalf_over_alpha_speed
		posVel = (exp1 - exp2) * negHalf_over_alpha_speed / speed
		velPos = (exp2 - exp1) * negHalf_over_alpha_speed * speed
		velVel = (exp1 * z1 - exp2 * z2) * negHalf_over_alpha_speed

	elseif damping == 1 then
		-- critically damped spring

		local time_speed = time * speed
		local time_speed_neg1 = time_speed * -1
		local exp = math.exp(time_speed_neg1)

		posPos = exp * (time_speed + 1)
		posVel = exp * time
		velPos = exp * (time_speed_neg1 * speed)
		velVel = exp * (time_speed_neg1 + 1)
	else
		-- underdamped spring

		local alpha = speed * math.sqrt(1 - damping^2)
		local overAlpha = 1 / alpha
		local exp = math.exp(-1 * time * speed * damping)
		local sin = math.sin(alpha * time)
		local cos = math.cos(alpha * time)
		local exp_sin = exp * sin
		local exp_cos = exp * cos
		local exp_sin_speed_damping_overAlpha = exp_sin * speed * damping * overAlpha

		posPos = exp_sin_speed_damping_overAlpha + exp_cos
		posVel = exp_sin * overAlpha
		velPos = -1 * ( exp_sin * alpha + speed * damping * exp_sin_speed_damping_overAlpha )
		velVel = exp_cos - exp_sin_speed_damping_overAlpha
	end

	return posPos, posVel, velPos, velVel
end

return springCoefficients
