--[[
	The entry point for the Fusion library.
]]

local Types = require(script.Types)
local restrictRead = require(script.Utility.restrictRead)

export type State<T> = Types.State<T>
export type StateOrValue<T> = Types.StateOrValue<T>
export type Symbol = Types.Symbol
export type Computed<T> = Types.Computed<T>
export type Compat = Types.Compat
export type Tween<T> = Types.Tween<T>
export type Spring<T> = Types.Spring<T>

type Fusion = {
  New: (className: string) -> ((propertyTable: {[string | Types.Symbol]: any}) -> Instance | nil),
  Children: Types.Symbol,
  OnEvent: (eventName: string) -> Types.Symbol,
  OnChange: (propertyName: string) -> Types.Symbol,

  State: (initialValue: any) -> State<any>,
  Computed: (callback: () -> any) -> Computed<any>,
  ComputedPairs: (inputTable: Types.StateOrValue<{[any]: any}>, processor: (any) -> any, destructor: (any) -> ()?) -> Computed<any>,
  Compat: (watchedState: Types.State<any>) -> Compat,

  Tween: (goalState: Types.State<Types.Animatable>, tweenInfo: TweenInfo?) -> Tween<any>,
  Spring: (goalState: Types.State<Types.Animatable>, speed: number?, damping: number?) -> Spring<any>
}

return restrictRead("Fusion", {
	New = require(script.Instances.New),
	Children = require(script.Instances.Children),
	OnEvent = require(script.Instances.OnEvent),
	OnChange = require(script.Instances.OnChange),

	State = require(script.State.State),
	Computed = require(script.State.Computed),
	ComputedPairs = require(script.State.ComputedPairs),
	Compat = require(script.State.Compat),

	Tween = require(script.Animation.Tween),
	Spring = require(script.Animation.Spring)
}) :: Fusion