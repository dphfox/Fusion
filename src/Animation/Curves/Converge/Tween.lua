--[[
	Returns to zero displacement based on a TweenInfo.
]]

-- TODO: type annotate this file

local easingStyles = {
	[Enum.EasingStyle.Linear] = {
		function(time)
			return time
		end,
		function(time)
			return 1
		end
	},
	[Enum.EasingStyle.Sine] = {
		function(time)
			return math.sin(math.pi * time / 2)
		end,
		function(time)
			return 0.5 * math.pi * math.cos(math.pi * time / 2)
		end,
		function(time)
			return 0.25 * math.pi^2 * -math.sin(math.pi * time / 2)
		end,
		function(time)
			return 0.125 * math.pi^3 * -math.cos(math.pi * time / 2)
		end,
		function(time)
			return 0.0625 * math.pi^4 * math.sin(math.pi * time / 2)
		end,
		function(time)
			return 0.03125 * math.pi^5 * math.cos(math.pi * time / 2)
		end,
		function(time)
			return 0.015625 * math.pi^6 * -math.sin(math.pi * time / 2)
		end
	},
	[Enum.EasingStyle.Quad] = {
		function(time)
			return 1 - (1 - time)^2
		end,
		function(time)
			return 2 * (1 - time)
		end,
		function(time)
			return -2
		end
	},
	[Enum.EasingStyle.Cubic] = {
		function(time)
			return 1 - (1 - time)^3
		end,
		function(time)
			return 3 * (1 - time)^2
		end,
		function(time)
			return -6 * (1 - time)
		end,
		function(time)
			return 6
		end
	},
	[Enum.EasingStyle.Quart] = {
		function(time)
			return 1 - (1 - time)^4
		end,
		function(time)
			return 4 * (1 - time)^3
		end,
		function(time)
			return -12 * (1 - time)^2
		end,
		function(time)
			return 24 * (1 - time)
		end,
		function(time)
			return -24
		end
	},
	[Enum.EasingStyle.Quint] = {
		function(time)
			return 1 - (1 - time)^5
		end,
		function(time)
			return 5 * (1 - time)^4
		end,
		function(time)
			return -20 * (1 - time)^3
		end,
		function(time)
			return 60 * (1 - time)^2
		end,
		function(time)
			return -120 * (1 - time)
		end,
		function(time)
			return 120
		end
	},
	[Enum.EasingStyle.Exponential] = {
		function(time)
			return 1 - 2^(-time * 10)
		end,
		function(time)
			return 2^(1 - time * 10) * 5 * math.log(2)
		end,
		function(time)
			return 2^(2 - time * 10) * -25 * math.log(2)^2
		end,
		function(time)
			return 2^(3 - time * 10) * 125 * math.log(2)^3
		end,
		function(time)
			return 2^(4 - time * 10) * -625 * math.log(2)^4
		end,
		function(time)
			return 2^(5 - time * 10) * 3125 * math.log(2)^5
		end,
		function(time)
			return 2^(6 - time * 10) * -15625 * math.log(2)^6
		end
	},
	[Enum.EasingStyle.Circular] = {
		function(time)
			return (-time * (time - 2))^(1/2)
		end,
		function(time)
			return (1 - time) / (-time * (time - 2))^(1/2)
		end,
		function(time)
			return -1 / (-time * (time - 2))^(3/2)
		end,
		function(time)
			return (3 - 3 * time) / (-time * (time - 2))^(5/2)
		end,
		function(time)
			return (15 - 24 * time + 12 * time^2) / (-time * (time - 2))^(7/2)
		end,
		function(time)
			return (-105 + 225 * time - 180 * time^2 + 60 * time^3) / (-time * (time - 2))^(9/2)
		end,
		function(time)
			return (-945 + 2520 * time - 2700 * time^2 + 1440 * time^3 - 360 * time^4) / (-time * (time - 2))^(11/2)
		end
	},
	[Enum.EasingStyle.Back] = {
		function(time)
			return 1 + 1.70158 * (time - 1)^2 + 2.70158 * (time - 1)^3
		end,
		function(time)
			return 3.40316 * (time - 1) + 8.10474 * (time - 1)^2
		end,
		function(time)
			return 3.40316 + 16.20948 * (time - 1)
		end,
		function(time)
			return 16.20948
		end
	},
	[Enum.EasingStyle.Elastic] = {
		function(time)
			local theta = 20 * math.pi * time / 3
			return 1 - 2^(-10 * time) * math.cos(theta)
		end,
		function(time)
			local theta = 20 * math.pi * time / 3
			return 5/3
				* 2^(1 - 10 * time)
				* (
					math.cos(theta) * math.log(8)
					+ math.sin(theta) * 2 * math.pi
				)
		end,
		function(time)
			local theta = 20 * math.pi * time / 3
			return 25/9
				* 4^(1 - 5 * time)
				* (
					math.cos(theta) * (4 * math.pi^2 - math.log(8)^2)
					- math.sin(theta) * 2 * math.pi * math.log(64)
				)
		end,
		function(time)
			local theta = 20 * math.pi * time / 3
			return 125/27
				* 4^(1 - 5 * time)
				* (
					math.cos(theta) * (-72 * math.pi^2 * math.log(2) + 54 * math.log(2)^3)
					+ math.sin(theta) * 4 * math.pi * (-4 * math.pi^2 + 27 * math.log(2)^2)
				)
		end,
		function(time)
			local theta = 20 * math.pi * time / 3
			return 625/81
				* 4^(2 - 5 * time)
				* (
					math.cos(theta) * (-16 * math.pi^4 + 216 * math.pi^2 * math.log(2)^2 - 81 * math.log(2)^4)
					+ math.sin(theta) * 24 * math.pi * math.log(2) * (4 * math.pi^2 - 9 * math.log(2)^2)
				)
		end,
		function(time)
			local theta = 20 * math.pi * time / 3
			return 3125/243
				* 4^(2 - 5 * time)
				* (
					math.cos(theta) * 6 * math.log(2) * (
						80 * math.pi^4 - 360 * math.pi^2 * math.log(2)^2 + 81 * math.log(2)^4
					)
					+ math.sin(theta) * 4 * math.pi * (
						16 * math.pi^4 - 360 * math.pi^2 - math.log(2)^2 + 405 * math.log(2)^4
					)
				)
		end,
		function(time)
			local theta = 20 * math.pi * time / 3
			return 15625/729
				* 4^(3 - 5 * time)
				* (
					math.cos(theta) * (
						64 * math.pi^6- 2160 * math.pi^4 * math.log(2)^2
						+ 4860 * math.pi^2 * math.log(2)^4 - 729 * math.log(2)^6
					)
					- math.sin(theta) * 36 * math.pi * math.log(2) * (
						16 * math.pi^4 - 120 * math.pi^2 * math.log(2)^2 + 91 * math.log(2)^4
					)
				)
		end
	},
	[Enum.EasingStyle.Bounce] = {
		function(time)
			if time < 1/2.75 then
				return 7.5625 * time^2
			elseif time < 2/2.75 then
				return 7.5625 * (time - 1.5/2.75)^2 + 0.75
			elseif time < 2.5/2.75 then
				return 7.5625 * (time - 2.25/2.75)^2 + 0.9375
			else
				return 7.5625 * (time - 2.625/2.75)^2 + 0.984375
			end
		end,
		function(time)
			if time < 1/2.75 then
				return 15.125 * time
			elseif time < 2/2.75 then
				return 15.125 * (time - 1.5/2.75)
			elseif time < 2.5/2.75 then
				return 15.125 * (time - 2.25/2.75)
			else
				return 15.125 * (time - 2.625/2.75)
			end
		end,
		function(time)
			return 15.125
		end
	},
}

local function sample(curves, derivative, curveX, x, y, width, height)
	local sample = height * (1/width)^(derivative - 1) * curves[derivative]((curveX - x)/width)
	if derivative == 1 then
		sample += y
	end
	return sample
end

local function sampleDirection(curves, derivative, easeDirection, curveX, x, y, width, height)
	if easeDirection == Enum.EasingDirection.In then
		x += width
		y += height
		width *= -1
		height *= -1
	elseif easeDirection == Enum.EasingDirection.InOut then
		local localX = (curveX - x) / width
		width /= 2
		height /= 2
		x += width
		y += height
		if localX <= 0.5 then
			width *= -1
			height *= -1
		end
	end
	return sample(curves, derivative, curveX, x, y, width, height)
end

local function sampleDirectionReversing(curves, derivative, easeDirection, withReverse, curveX, x, y, width, height)
	if withReverse then
		local localX = (curveX - x) / width
		if localX > 0.5 then
			x += width
			width *= -1
		end
		width /= 2
	end
	return sampleDirection(curves, derivative, easeDirection, curveX, x, y, width, height)
end

local function Tween(tweenInfo)
	local delay = tweenInfo.DelayTime
	local duration = tweenInfo.Time
	local reverses = tweenInfo.Reverses
	local repeatCount = tweenInfo.RepeatCount
	local easeStyle = tweenInfo.EasingStyle
	local easeDirection = tweenInfo.EasingDirection

	local repeatDuration = duration
	if reverses then
		repeatDuration *= 2
	end
	repeatDuration += delay

	return function(initialValues)
		local dimension = #initialValues[1]
		local zero = table.create(dimension, 0)
		local initialDisplacement = initialValues[1]

		local easingStyle = easingStyles[easeStyle]
		local curves = table.create(#easingStyle)
		for derivativeNum, derivativeCurve in easingStyle do
			curves[derivativeNum] = function(time)
				local repeatsElapsed = math.ceil(time / repeatDuration) - 1
				if repeatsElapsed < 0 then -- before tween started
					return
						if derivativeNum == 1
						then initialDisplacement
						else zero
				elseif repeatCount >= 0 and repeatsElapsed > 1 + repeatCount then -- after tween ended
					return
						if derivativeNum == 1 and reverses
						then initialDisplacement
						else zero
				elseif time - (repeatsElapsed * repeatDuration) < delay then -- waiting during delay period
					return
						if derivativeNum == 1 and (reverses or repeatsElapsed == 0)
						then initialDisplacement
						else zero
				else -- during tween motion
					local output = table.create(dimension, 0)
					for index in output do
						output[index] = sampleDirectionReversing(
							derivativeCurve,
							derivativeNum,
							easeDirection,
							reverses,
							time,
							repeatsElapsed * repeatDuration + delay,
							initialDisplacement[index],
							repeatDuration - delay,
							-initialDisplacement[index]
						)
					end
					return output
				end
			end
		end

		return curves
	end
end

return Tween