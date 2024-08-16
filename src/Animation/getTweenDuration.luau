--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Given a `tweenInfo`, returns how many seconds it will take before the tween
	finishes moving. The result may be infinite if the tween repeats forever.
]]

local TweenService = game:GetService("TweenService")

local function getTweenDuration(
	tweenInfo: TweenInfo
): number
	if tweenInfo.RepeatCount <= -1 then
		return math.huge
	end
	local tweenDuration = tweenInfo.DelayTime + tweenInfo.Time
	if tweenInfo.Reverses then
		tweenDuration += tweenInfo.Time
	end
	tweenDuration *= tweenInfo.RepeatCount + 1
	return tweenDuration
end

return getTweenDuration
