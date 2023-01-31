--!strict

--[[
	The entry point for the Fusion library.
]]

local PubTypes = require(script.PubTypes)
local restrictRead = require(script.Utility.restrictRead)

-- Fusion / State /

export type CanBeState<T> = PubTypes.CanBeState<T>
export type Computed<T, M> = PubTypes.Computed<T, M>
export type Dependency = PubTypes.Dependency
export type Dependent = PubTypes.Dependent
export type ForKeys<KI, KO, V, M> = PubTypes.ForKeys<KI, KO, V, M>
export type ForPairs<KI, VI, KO, VO, M> = PubTypes.ForPairs<KI, VI, KO, VO, M>
export type ForValues<K, VI, VO, M> = PubTypes.ForValues<K, VI, VO, M>
export type Observer = PubTypes.Observer
export type StateObject<T> = PubTypes.StateObject<T>
export type Value<T> = PubTypes.Value<T>

-- Fusion / Instances /

export type Child = PubTypes.Child
export type Children = PubTypes.Children
export type Cleanup = PubTypes.Cleanup
export type Component = PubTypes.Component
export type Hydrate = PubTypes.Hydrate
export type New = PubTypes.New
export type OnChange = PubTypes.OnChange
export type OnEvent = PubTypes.OnEvent
export type Out = PubTypes.Out
export type Ref = PubTypes.Ref
export type SpecialKey = PubTypes.SpecialKey

-- Fusion / Animation /

export type Animatable = PubTypes.Animatable
export type Tween<T> = PubTypes.Tween<T>
export type Spring<T> = PubTypes.Spring<T>

local Fusion = {
	version = {major = 0, minor = 2, isRelease = false},

	-- Fusion / State /

	Computed = require(script.State.Computed) :: (
		<T, M>(
			processor: () -> (T, M),
			destructor: ((T, M) -> ())?
		) -> Computed<T, M>
	),
	cleanup = require(script.Utility.cleanup) :: (
		(...any) -> ()
	),
	doNothing = require(script.Utility.doNothing) :: (
		(...any) -> ()
	),
	ForKeys = require(script.State.ForKeys) :: (
		<KI, KO, V, M>(
			input: CanBeState<{[KI]: V}>,
			keyProcessor: (KI, M) -> (KO, M),
			keyDestructor: ((KO, M) -> ())?
		) -> ForKeys<KI, KO, V, M>
	),
	ForPairs = require(script.State.ForPairs) :: (
		<KI, VI, KO, VO, M>(
			input: CanBeState<{[KI]: VI}>,
			pairProcessor: (KI, VI, M) -> (KO, VO, M),
			pairDestructor: ((KO, VO, M) -> ())?
		) -> ForPairs<KI, VI, KO, VO, M>
	),
	ForValues = require(script.State.ForValues) :: (
		<K, VI, VO, M>(
			input: CanBeState<{[K]: VI}>,
			valueProcessor: (VI, M) -> (VO, M),
			valueDestructor: ((VO, M) -> ())?
		) -> ForValues<K, VI, VO, M>
	),
	Observer = require(script.State.Observer) :: (
		(
			observe: Dependency
		) -> Observer
	),
	Value = require(script.State.Value) :: (
		<T>(
			initialValue: T
		) -> Value<T>
	),

	-- Fusion / Instances /

	Children = require(script.Instances.Children) :: (
		PubTypes.SpecialKey
	),
	Cleanup = require(script.Instances.Cleanup) :: (
		PubTypes.Cleanup
	),
	Hydrate = require(script.Instances.Hydrate) :: (
		PubTypes.Hydrate
	),
	New = require(script.Instances.New) :: (
		PubTypes.New
	),
	OnChange = require(script.Instances.OnChange) :: (
		(propertyName: string) -> OnChange
	),
	OnEvent = require(script.Instances.OnEvent) :: (
		(eventName: string) -> OnEvent
	),
	Out = require(script.Instances.Out) :: (
		(propertyName: string) -> OnChange
	),
	Ref = require(script.Instances.Ref) :: (
		PubTypes.Ref
	),

	-- Fusion / Animation /

	Tween = require(script.Animation.Tween) :: (
		<T>(
			goal: StateObject<T>,
			tweenInfo: CanBeState<TweenInfo>?
		) -> Tween<T>
	),
	Spring = require(script.Animation.Spring) :: (
		<T>(
			goal: StateObject<T>,
			speed: CanBeState<number>?,
			damping: CanBeState<number>?
		) -> Spring<T>
	)
}

return restrictRead("Fusion", Fusion) :: typeof(Fusion)
