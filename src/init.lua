--!strict

--[[
	The entry point for the Fusion library.
]]

local PubTypes = require(script.PubTypes)
local restrictRead = require(script.Utility.restrictRead)

export type StateObject<T> = PubTypes.StateObject<T>
export type StateOrValue<T> = PubTypes.StateOrValue<T>
export type Symbol = PubTypes.Symbol
export type State<T> = PubTypes.State<T>
export type Computed<T> = PubTypes.Computed<T>
export type ComputedPairs<K, V> = PubTypes.ComputedPairs<K, V>
export type Compat = PubTypes.Compat
export type Tween<T> = PubTypes.Tween<T>
export type Spring<T> = PubTypes.Spring<T>

type Fusion = {
  New: (className: string) -> ((propertyTable: PubTypes.PropertyTable) -> Instance),
  Children: PubTypes.ChildrenKey,
  OnEvent: (eventName: string) -> PubTypes.OnEventKey,
  OnChange: (propertyName: string) -> PubTypes.OnChangeKey,

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