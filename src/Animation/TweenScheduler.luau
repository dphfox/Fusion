--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Manages batch updating of tween objects.
]]

local Package = script.Parent.Parent
local InternalTypes = require(Package.InternalTypes)
local External = require(Package.External)
local lerpType = require(Package.Animation.lerpType)
local getTweenRatio = require(Package.Animation.getTweenRatio)
local updateAll = require(Package.State.updateAll)

local TweenScheduler = {}

type Set<T> = {[T]: unknown}

-- all the tweens currently being updated
local allTweens: Set<InternalTypes.Tween<unknown>> = {}

--[[
	Adds a Tween to be updated every render step.
]]
function TweenScheduler.add(
	tween: InternalTypes.Tween<unknown>
)
	allTweens[tween] = true
end

--[[
	Removes a Tween from the scheduler.
]]
function TweenScheduler.remove(
	tween: InternalTypes.Tween<unknown>
)
	allTweens[tween] = nil
end

--[[
	Updates all Tween objects.
]]
local function updateAllTweens(
	now: number
)
	for tween in allTweens do
		local currentTime = now - tween._currentTweenStartTime

		if currentTime > tween._currentTweenDuration and tween._currentTweenInfo.RepeatCount > -1 then
			if tween._currentTweenInfo.Reverses then
				tween._currentValue = tween._prevValue
			else
				tween._currentValue = tween._nextValue
			end
			tween._currentlyAnimating = false
			updateAll(tween)
			TweenScheduler.remove(tween)
		else
			local ratio = getTweenRatio(tween._currentTweenInfo, currentTime)
			local currentValue = lerpType(tween._prevValue, tween._nextValue, ratio)
			tween._currentValue = currentValue
			tween._currentlyAnimating = true
			updateAll(tween)
		end
	end
end

External.bindToUpdateStep(updateAllTweens)

return TweenScheduler