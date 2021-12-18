--!nonstrict

--[[
    Centralizes all RunService connections so that the various parts of Fusion 
    don't connect to RunService independently of one another.

    You can optionally pause all internal updating by calling `:pause()`, and
    then resume updating by calling `:resume()`.

    If you want to manually control the update process, you can call
    `.thread:Disconnect()`, since `.thread` is a Roblox Signal. After doing this, 
    you then just need to account for throttling using the `.throttling` property,
    and call `.stepped:Fire(dt)` whenever you want; `dt` here is just the change in 
    time since the last update call.
]]

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent
local Signal = require(Package.Parent.Signal)

local class = {}
class.__index = class

function class.new()
    local self = setmetatable({}, class)

    self.stepped = Signal.new()
    self.throttling = false
    self.thread = (RunService:IsServer() and self.Stepped or self.RenderStepped):Connect(function(dt)
        if not self.Throttling then
            self.stepped:Fire(dt)
        end
    end)

    return self
end

function class:bindToStep(func)
    return self.Stepped:Connect(func)
end

function class:pause()
    self.Throttling = true
end

function class:play()
    self.Throttling = false
end

-- Return a Singleton of the Updater class
return class.new()