--!nonstrict

--[[
    Centralizes all RunService connections so that the various parts of Fusion 
    don't connect to RunService independently of one another. This returns a
    singleton, and therefore its functions all use lua object syntax with `:function()`.

    You can optionally pause all internal updating by calling `:pause()`, and
    then resume updating by calling `:resume()`.
]]

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent
local Signal = require(Package.Parent.Signal)

local singleton = {}

singleton._stepped = Signal.new
singleton._paused = false
singleton._thread = (RunService:IsServer() and RunService.Stepped or RunService.RenderStepped):Connect(function(dt)
    if not singleton._paused then
        singleton._stepped:Fire(dt)
    end
end)

--[[
    Binds a function to be called whenever the Updater gets stepped. By default, this function will
    be called with `RunService.Stepped` on the server and `RunService.RenderStepped` on the client.

    For future-proofing reasons you should not directly call ``._stepped:Connect(func)``
]]
function singleton:bindToStep(func)
    return singleton._stepped:Connect(func)
end

--[[
    Pauses the execution of updates. Updates will resume as soon as you call `:resume()`
]]
function singleton:pause()
    singleton._paused = true
end

--[[
    Resumes the execution of updates.
]]
function singleton:resume()
    singleton._paused = false
end

return singleton