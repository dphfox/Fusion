local RunService = game:GetService("RunService")

local TweenScheduler = require(script.Parent.Animation.TweenScheduler)
local SpringScheduler = require(script.Parent.Animation.SpringScheduler)

local function bindScheduler()
    if RunService:IsClient() then
        RunService:BindToRenderStep(
            "__FusionTweenScheduler",
            Enum.RenderPriority.First.Value,
            TweenScheduler.updateAllTweens
        )
        RunService:BindToRenderStep(
            "__FusionSpringScheduler",
            Enum.RenderPriority.First.Value,
            SpringScheduler.updateAllSprings
        )
    else
        RunService.Heartbeat:Connect(TweenScheduler.updateAllTweens)
        RunService.Heartbeat:Connect(SpringScheduler.updateAllSprings)
    end
end

return bindScheduler