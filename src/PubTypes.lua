--!strict

--[[
	Stores common public-facing type information for Fusion APIs.
]]

type Set<T> = {[T]: any}

--[[
	General use types
]]

-- A unique symbolic value.
export type Symbol = {
	type: "Symbol",
	name: string
}

-- Types that can be expressed as vectors of numbers, and so can be animated.
export type Animatable =
	number |
	CFrame |
	Color3 |
	ColorSequenceKeypoint |
	DateTime |
	NumberRange |
	NumberSequenceKeypoint |
	PhysicalProperties |
	Ray |
	Rect |
	Region3 |
	Region3int16 |
	UDim |
	UDim2 |
	Vector2 |
	Vector2int16 |
	Vector3 |
	Vector3int16

-- A task which can be accepted for cleanup.
export type Task =
	Instance |
	RBXScriptConnection |
	() -> () |
	{destroy: (any) -> ()} |
	{Destroy: (any) -> ()} |
	{Task}

-- A scope of tasks to clean up.
export type Scope<Constructors> = {Task} & Constructors

-- An object which uses a scope to dictate how long it lives.
export type ScopeLifetime = {
	scope: Scope<any>
}

-- Script-readable version information.
export type Version = {
	major: number,
	minor: number,
	isRelease: boolean
}
--[[
	Generic reactive graph types
]]

-- A graph object which can have dependents.
export type Dependency = ScopeLifetime & {
	dependentSet: Set<Dependent>
}

-- A graph object which can have dependencies.
export type Dependent = {
	update: (Dependent) -> boolean,
	dependencySet: Set<Dependency>
}

-- An object which stores a piece of reactive state.
export type StateObject<T> = Dependency & {
	type: "State",
	kind: string,
	_typeIdentifier: T
}

-- Either a constant value of type T, or a state object containing type T.
export type CanBeState<T> = StateObject<T> | T

-- Function signature for use callbacks.
export type Use = <T>(target: CanBeState<T>) -> T

--[[
	Specific reactive graph types
]]

-- A state object whose value can be set at any time by the user.
export type Value<T> = StateObject<T> & {
	kind: "State",
 	set: (Value<T>, newValue: any, force: boolean?) -> (),
	destroy: () -> ()
}
type ValueConstructor = <T>(
	scope: Scope<any>,
	initialValue: T
) -> Value<T>

-- A state object whose value is derived from other objects using a callback.
export type Computed<T> = StateObject<T> & Dependent & {
	kind: "Computed",
	destroy: () -> ()
}
type ComputedConstructor = <T, S>(
	scope: Scope<S>,
	callback: (Scope<S>, Use) -> T
) -> Computed<T>

-- A state object which maps over keys and/or values in another table.
export type For<KO, VO> = StateObject<{[KO]: VO}> & Dependent & {
	kind: "For",
	destroy: () -> ()
}
type ForPairsConstructor =  <KI, KO, VI, VO, S>(
	scope: Scope<S>,
	inputTable: CanBeState<{[KI]: VI}>,
	processor: (Scope<S>, Use, KI, VI) -> (KO, VO)
) -> For<KO, VO>
type ForKeysConstructor =  <KI, KO, V, M, S>(
	scope: Scope<S>,
	inputTable: CanBeState<{[KI]: V}>,
	processor: (Scope<S>, Use, KI) -> (KO, M?)
) -> For<KO, V>
type ForValuesConstructor =  <K, VI, VO, M, S>(
	scope: Scope<S>,
	inputTable: CanBeState<{[K]: VI}>,
	processor: (Scope<S>, Use, VI) -> (VO, M?)
) -> For<K, VO>

-- An object which can listen for updates on another state object.
export type Observer = Dependent & {
	kind: "Observer",
	onChange: (Observer, callback: () -> ()) -> (() -> ()),
	destroy: () -> ()
}
type ObserverConstructor = (
	scope: Scope<any>,
	watchedState: StateObject<any>
) -> Observer

-- A state object which follows another state object using tweens.
export type Tween<T> = StateObject<T> & Dependent & {
	kind: "Tween",
	destroy: () -> ()
}
type TweenConstructor = <T>(
	scope: Scope<any>,
	goalState: StateObject<T>,
	tweenInfo: TweenInfo?
) -> Tween<T>

-- A state object which follows another state object using spring simulation.
export type Spring<T> = StateObject<T> & Dependent & {
	kind: "Spring",
	setPosition: (Spring<T>, newPosition: Animatable) -> (),
	setVelocity: (Spring<T>, newVelocity: Animatable) -> (),
	addVelocity: (Spring<T>, deltaVelocity: Animatable) -> (),
	destroy: () -> ()
}
type SpringConstructor = <T>(
	scope: Scope<any>,
	goalState: StateObject<T>,
	speed: CanBeState<number>?,
	damping: CanBeState<number>?
) -> Spring<T>

--[[
	Instance related types
]]

-- Denotes children instances in an instance or component's property table.
export type SpecialKey = {
	type: "SpecialKey",
	kind: string,
	stage: "self" | "descendants" | "ancestor" | "observer",
	apply: (
		self: SpecialKey,
		scope: Scope<any>,
		value: any,
		applyTo: Instance
	) -> ()
}

-- A collection of instances that may be parented to another instance.
export type Children = Instance | StateObject<Children> | {[any]: Children}

-- A table that defines an instance's properties, handlers and children.
export type PropertyTable = {[string | SpecialKey]: any}

type NewConstructor = (
	scope: Scope<any>,
	className: string
) -> (propertyTable: PropertyTable) -> Instance

type HydrateConstructor = (
	scope: Scope<any>,
	target: Instance
) -> (propertyTable: PropertyTable) -> Instance

export type Fusion = {
	version: Version,

	doCleanup: (...any) -> (),
	doNothing: (...any) -> (),
	scoped: <T>(constructors: T) -> Scope<T>,
	deriveScope: <S>(scope: Scope<S>) -> Scope<S>,

	peek: Use,
	Value: ValueConstructor,
	Computed: ComputedConstructor,
	ForPairs: ForPairsConstructor,
	ForKeys: ForKeysConstructor,
	ForValues: ForValuesConstructor,
	Observer: ObserverConstructor,

	Tween: TweenConstructor,
	Spring: SpringConstructor,

	New: NewConstructor,
	Hydrate: HydrateConstructor,

	Ref: SpecialKey,
	Cleanup: SpecialKey,
	Children: SpecialKey,
	Out: (propertyName: string) -> SpecialKey,
	OnEvent: (eventName: string) -> SpecialKey,
	OnChange: (propertyName: string) -> SpecialKey,
	Attribute: (attributeName: string) -> SpecialKey,
	AttributeChange: (attributeName: string) -> SpecialKey,
	AttributeOut: (attributeName: string) -> SpecialKey,
	
}

return nil
