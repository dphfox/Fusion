--[[
	Manages batch updating of tween objects.
]]

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent
local Types = require(Package.Types)
local lerpType = require(Package.Animation.lerpType)
local getTweenRatio = require(Package.Animation.getTweenRatio)
local updateAll = require(Package.Dependencies.updateAll)

local TweenScheduler = {}

type Tween = {
	_prevValue: Types.Animatable,
	_nextValue: Types.Animatable,
	_currentValue: Types.Animatable,

	_tweenStartTime: number,
	_tweenDuration: number,
	_tweenInfo: TweenInfo
}

local WEAK_KEYS_METATABLE = {__mode = "k"}

-- all the tweens currently being updated
local allTweens: Types.Set<Tween> = setmetatable({}, WEAK_KEYS_METATABLE)

--[[
	Adds a Tween to be updated every render step.
]]
function TweenScheduler.add(tween: Tween)
	allTweens[tween] = true
end

--[[
	Removes a Tween from the scheduler.
]]
function TweenScheduler.remove(tween: Tween)
	allTweens[tween] = nil
end

--[[
	Updates all Tween objects.
]]
local function updateAllTweens()
	local now = os.clock()
	for tween in pairs(allTweens) do
		local currentTime = now - tween._currentTweenStartTime

		if currentTime > tween._currentTweenDuration then
			if tween._currentTweenInfo.Reverses then
				tween._currentValue = tween._prevValue
			else
				tween._currentValue = tween._nextValue
			end
			updateAll(tween)
			TweenScheduler.remove(tween)
		else
			local ratio = getTweenRatio(tween._currentTweenInfo, currentTime)
			local currentValue = lerpType(tween._prevValue, tween._nextValue, ratio)
			tween._currentValue = currentValue
			updateAll(tween)
		end
	end
end

RunService:BindToRenderStep(
	"__FusionTweenScheduler",
	Enum.RenderPriority.First.Value,
	updateAllTweens
)

return TweenScheduler