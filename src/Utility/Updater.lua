--!nonstrict

--[[
    Centralizes all RunService connections so that the various parts of Fusion 
    don't connect to RunService independently of one another.

    You can optionally pause all internal updating by calling `.pause()`, and
    then resume updating by calling `.resume()`.
]]

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent
local Signal = require(Package.Parent.Signal)

local Updater = {}

local stepped = Signal.new
local paused = false
local thread = (RunService:IsServer() and RunService.Stepped or RunService.RenderStepped):Connect(function(dt)
    if paused == false then
        stepped:Fire(dt)
    end
end)

--[[
    Binds a function to be called whenever the Updater gets stepped. By default, this function will
    be called with `RunService.Stepped` on the server and `RunService.RenderStepped` on the client.
]]
function Updater.bindToStep(func)
    return stepped:Connect(func)
end

--[[
    Pauses the execution of updates. Updates will resume as soon as you call `.resume()`
]]
function Updater.pause()
    paused = true
end

--[[
    Resumes the execution of updates.
]]
function Updater.resume()
    paused = false
end

return Updater