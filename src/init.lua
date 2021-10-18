--!strict

--[[
	The entry point for the Fusion library.
]]

local Types = require(script.Types)
local restrictRead = require(script.Utility.restrictRead)

export type StateObject<T> = Types.StateObject<T>
export type StateOrValue<T> = Types.StateOrValue<T>
export type Symbol = Types.Symbol
export type State<T> = Types.State<T>
export type Computed<T> = Types.Computed<T>
export type ComputedPairs<K, V> = Types.ComputedPairs<K, V>
export type Compat = Types.Compat
export type Tween<T> = Types.Tween<T>
export type Spring<T> = Types.Spring<T>

type Fusion = {
  New: (className: string) -> ((propertyTable: Types.PropertyTable) -> Instance),
  Children: Types.ChildrenKey,
  OnEvent: (eventName: string) -> Types.OnEventKey,
  OnChange: (propertyName: string) -> Types.OnChangeKey,

  State: <T>(initialValue: T) -> State<T>,
  Computed: <T>(callback: () -> T) -> Computed<T>,
  ComputedPairs: <K, VI, VO>(inputTable: StateOrValue<{[K]: VI}>, processor: (K, VI) -> VO, destructor: (VO) -> ()?) -> ComputedPairs<K, VO>,
  Compat: (watchedState: StateObject<any>) -> Compat,

  Tween: <T>(goalState: StateObject<T>, tweenInfo: TweenInfo?) -> Tween<T>,
  Spring: <T>(goalState: StateObject<T>, speed: number?, damping: number?) -> Spring<T>
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