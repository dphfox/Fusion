--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Given a `tweenInfo` and `currentTime`, returns a ratio which can be used to
	tween between two values over time.
]]

local TweenService = game:GetService("TweenService")

local function getTweenRatio(
	tweenInfo: TweenInfo,
	currentTime: number
): number
	local delay = tweenInfo.DelayTime
	local duration = tweenInfo.Time
	local reverses = tweenInfo.Reverses
	local numCycles = 1 + tweenInfo.RepeatCount
	local easeStyle = tweenInfo.EasingStyle
	local easeDirection = tweenInfo.EasingDirection
	local cycleDuration = delay + duration
	if reverses then
		cycleDuration += duration
	end
	-- If currentTime is infinity, then presumably the tween should be over.
	-- This avoids NaN when the duration of an infinitely repeating tween is given.
	if currentTime == math.huge then
		return 1
	end
	if currentTime >= cycleDuration * numCycles and tweenInfo.RepeatCount > -1 then
		return 1
	end
	local cycleTime = currentTime % cycleDuration
	if cycleTime <= delay then
		return 0
	end
	local tweenProgress = (cycleTime - delay) / duration
	if tweenProgress > 1 then
		tweenProgress = 2 - tweenProgress
	end
	local ratio = TweenService:GetValue(tweenProgress, easeStyle, easeDirection)
	return ratio
end

return getTweenRatio
