--[[
	The entry point for the Fusion library.
]]

local Types = require(script.Types)
local restrictRead = require(script.Utility.restrictRead)

export type State<T> = Types.State<T>
export type StateOrValue<T> = Types.StateOrValue<T>
export type Symbol = Types.Symbol

return restrictRead("Fusion", {
	New = require(script.Instances.New),
	CreateElement = require(script.Instances.CreateElement),
	Children = require(script.Instances.Children),
	OnEvent = require(script.Instances.OnEvent),
	OnChange = require(script.Instances.OnChange),

	State = require(script.State.State),
	Computed = require(script.State.Computed),
	ComputedPairs = require(script.State.ComputedPairs),
	Compat = require(script.State.Compat),

	Tween = require(script.Animation.Tween),
	Spring = require(script.Animation.Spring)
})