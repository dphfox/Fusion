--[[
	The standard tween easing curves, and their first (up to) 6 derivatives.
	Note that these curves only ease out - to ease in, or both in and out, you
	can apply transformations to the inputs and outputs.
]]

-- TODO: type annotate this file

return {
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