--!strict

--[[
	The entry point for the Fusion library.
]]

local PubTypes = require(script.PubTypes)
local restrictRead = require(script.Utility.restrictRead)

export type StateObject<T> = PubTypes.StateObject<T>
export type CanBeState<T> = PubTypes.CanBeState<T>
export type Symbol = PubTypes.Symbol
export type Value<T> = PubTypes.Value<T>
export type Computed<T> = PubTypes.Computed<T>
export type ForPairs<KO, VO> = PubTypes.ForPairs<KO, VO>
export type ForKeys<KI, KO> = PubTypes.ForKeys<KI, KO>
export type ForValues<VI, VO> = PubTypes.ForKeys<VI, VO>
export type Observer = PubTypes.Observer
export type Tween<T> = PubTypes.Tween<T>
export type Spring<T> = PubTypes.Spring<T>

type Fusion = {
	version: PubTypes.Version,

	New: (className: string) -> ((propertyTable: PubTypes.PropertyTable) -> Instance),
	Hydrate: (target: Instance) -> ((propertyTable: PubTypes.PropertyTable) -> Instance),
	Ref: PubTypes.SpecialKey,
	Cleanup: PubTypes.SpecialKey,
	Children: PubTypes.SpecialKey,
	Out: PubTypes.SpecialKey,
	OnEvent: (eventName: string) -> PubTypes.SpecialKey,
	OnChange: (propertyName: string) -> PubTypes.SpecialKey,

	Value: <T>(initialValue: T) -> Value<T>,
	Computed: <T>(callback: () -> T, destructor: (T) -> ()?) -> Computed<T>,
	ForPairs: <KI, VI, KO, VO, M>(inputTable: CanBeState<{[KI]: VI}>, processor: (KI, VI) -> (KO, VO, M?), destructor: (KO, VO, M?) -> ()?) -> ForPairs<KO, VO>,
	ForKeys: <KI, KO, M>(inputTable: CanBeState<{[KI]: any}>, processor: (KI) -> (KO, M?), destructor: (KO, M?) -> ()?) -> ForKeys<KO, any>,
	ForValues: <VI, VO, M>(inputTable: CanBeState<{[any]: VI}>, processor: (VI) -> (VO, M?), destructor: (VO, M?) -> ()?) -> ForValues<any, VO>,
	Observer: (watchedState: StateObject<any>) -> Observer,

	Tween: <T>(goalState: StateObject<T>, tweenInfo: TweenInfo?) -> Tween<T>,
	Spring: <T>(goalState: StateObject<T>, speed: number?, damping: number?) -> Spring<T>,

	cleanup: (...any) -> (),
	doNothing: (...any) -> ()
}

return restrictRead("Fusion", {
	version = {major = 0, minor = 2, isRelease = true},

	New = require(script.Instances.New),
	Hydrate = require(script.Instances.Hydrate),
	Ref = require(script.Instances.Ref),
	Out = require(script.Instances.Out),
	Cleanup = require(script.Instances.Cleanup),
	Children = require(script.Instances.Children),
	OnEvent = require(script.Instances.OnEvent),
	OnChange = require(script.Instances.OnChange),

	Value = require(script.State.Value),
	Computed = require(script.State.Computed),
	ForPairs = require(script.State.ForPairs),
	ForKeys = require(script.State.ForKeys),
	ForValues = require(script.State.ForValues),
	Observer = require(script.State.Observer),

	Tween = require(script.Animation.Tween),
	Spring = require(script.Animation.Spring),

	cleanup = require(script.Utility.cleanup),
	doNothing = require(script.Utility.doNothing)
}) :: Fusion
