-- TODO: type annotate this file

local Package = script.Parent.Parent
local easingStyles = require(Package.easingStyles)

local function sample(curves, curveX, x, y, width, height)
	local samples = {}
	for derivative, curve in curves do
		samples[derivative] = height * (1/width)^(derivative - 1) * curve((curveX - x)/width)
	end
	samples[1] += y
	return samples
end

local function sampleDirection(curves, easeDirection, curveX, x, y, width, height)
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
	return sample(curves, curveX, x, y, width, height)
end

local function sampleDirectionReversing(curves, easeDirection, withReverse, curveX, x, y, width, height)
	if withReverse then
		local localX = (curveX - x) / width
		if localX > 0.5 then
			x += width
			width *= -1
		end
		width /= 2
	end
	return sampleDirection(curves, easeDirection, curveX, x, y, width, height)
end

local function ApproachTween(tweenInfo)
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

	return function(startDisplacement)
		startDisplacement = startDisplacement or 0
		return function(time)
			local repeatsElapsed = math.ceil(time / repeatDuration) - 1

			if repeatsElapsed < 0 then -- before tween started
				return startDisplacement
			elseif repeatCount >= 0 and repeatsElapsed > 1 + repeatCount then -- after tween ended
				local endValue = if reverses then startDisplacement else 0
				return endValue
			elseif time - (repeatsElapsed * repeatDuration) < delay then -- waiting during delay period
				local delayValue = if reverses or repeatsElapsed == 0 then startDisplacement else 0
				return delayValue
			else -- during tween motion
				local curves = easingStyles[easeStyle]
				return unpack(sampleDirectionReversing(
					curves,
					easeDirection,
					reverses,
					time,
					repeatsElapsed * repeatDuration + delay,
					startDisplacement,
					repeatDuration - delay,
					-startDisplacement
				))
			end
		end
	end
end

return ApproachTween