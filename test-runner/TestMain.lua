local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Fusion = require(ReplicatedStorage.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local State = Fusion.State
local Computed = Fusion.Computed
local ComputedPairs = Fusion.ComputedPairs

local Tween = Fusion.Spring

local pos = State(UDim2.fromScale(0.25, 0.25))

local gui = New "ScreenGui" {
    Parent = Players.LocalPlayer.PlayerGui,

    [Children] = New "Frame" {
        Position = Tween(pos),
        Size = UDim2.fromScale(0.1, 0.1)
    }
}
wait(5)
pos:set(UDim2.fromScale(0.75, 0.75))

return nil