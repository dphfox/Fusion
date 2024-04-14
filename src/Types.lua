--!strict
--!nolint LocalShadow

--[[
	Stores common public-facing type information for Fusion APIs.
]]

--[[
	General use types
]]

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
	{destroy: (unknown) -> ()} |
	{Destroy: (unknown) -> ()} |
	{Task}

-- A scope of tasks to clean up.
export type Scope<Constructors> = {unknown} & Constructors

-- An object which uses a scope to dictate how long it lives.
export type ScopedObject = {
	scope: Scope<unknown>?,
	destroy: () -> ()
}

-- Script-readable version information.
export type Version = {
	major: number,
	minor: number,
	isRelease: boolean
}

-- An object which stores a value scoped in time.
export type Contextual<T> = {
	type: "Contextual",
	now: (Contextual<T>) -> T,
	is: (Contextual<T>, T) -> ContextualIsMethods
}

type ContextualIsMethods = {
	during: <R, A...>(ContextualIsMethods, (A...) -> R, A...) -> R
}

--[[
	Generic reactive graph types
]]

-- A graph object which can have dependents.
export type Dependency = ScopedObject & {
	dependentSet: {[Dependent]: unknown}
}

-- A graph object which can have dependencies.
export type Dependent = ScopedObject & {
	update: (Dependent) -> boolean,
	dependencySet: {[Dependency]: unknown}
}

-- An object which stores a piece of reactive state.
export type StateObject<T> = Dependency & {
	type: "State",
	kind: string,
	[{}]: T -- unindexable phantom data so StateObject actually contains a T
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
 	set: (Value<T>, newValue: T, force: boolean?) -> ()
}
export type ValueConstructor = <T>(
	scope: Scope<unknown>,
	initialValue: T
) -> Value<T>

-- A state object whose value is derived from other objects using a callback.
export type Computed<T> = StateObject<T> & Dependent & {
	kind: "Computed"
}
export type ComputedConstructor = <T, S>(
	scope: Scope<S>,
	callback: (Use, Scope<S>) -> T
) -> Computed<T>

-- A state object which maps over keys and/or values in another table.
export type For<KO, VO> = StateObject<{[KO]: VO}> & Dependent & {
	kind: "For"
}
export type ForPairsConstructor =  <KI, KO, VI, VO, S>(
	scope: Scope<S>,
	inputTable: CanBeState<{[KI]: VI}>,
	processor: (Use, Scope<S>, key: KI, value: VI) -> (KO, VO)
) -> For<KO, VO>
export type ForKeysConstructor =  <KI, KO, V, S>(
	scope: Scope<S>,
	inputTable: CanBeState<{[KI]: V}>,
	processor: (Use, Scope<S>, key: KI) -> KO
) -> For<KO, V>
export type ForValuesConstructor =  <K, VI, VO, S>(
	scope: Scope<S>,
	inputTable: CanBeState<{[K]: VI}>,
	processor: (Use, Scope<S>, value: VI) -> VO
) -> For<K, VO>

-- An object which can listen for updates on another state object.
export type Observer = Dependent & {
	type: "Observer",
	onChange: (Observer, callback: () -> ()) -> (() -> ()),
	onBind: (Observer, callback: () -> ()) -> (() -> ())
}
export type ObserverConstructor = (
	scope: Scope<unknown>,
	watching: Dependency
) -> Observer

-- A state object which follows another state object using tweens.
export type Tween<T> = StateObject<T> & Dependent & {
	kind: "Tween"
}
export type TweenConstructor = <T>(
	scope: Scope<unknown>,
	goalState: StateObject<T>,
	tweenInfo: CanBeState<TweenInfo>?
) -> Tween<T>

-- A state object which follows another state object using spring simulation.
export type Spring<T> = StateObject<T> & Dependent & {
	kind: "Spring",
	setPosition: (Spring<T>, newPosition: T) -> (),
	setVelocity: (Spring<T>, newVelocity: T) -> (),
	addVelocity: (Spring<T>, deltaVelocity: T) -> ()
}
export type SpringConstructor = <T>(
	scope: Scope<unknown>,
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
		scope: Scope<unknown>,
		value: unknown,
		applyTo: Instance
	) -> ()
}

-- A collection of instances that may be parented to another instance.
export type Child = Instance | StateObject<Child> | {[unknown]: Child}

-- A table that defines an instance's properties, handlers and children.
export type PropertyTable = {[string | SpecialKey]: unknown}

export type NewConstructor = (
	scope: Scope<unknown>,
	className: string
) -> (propertyTable: PropertyTable) -> Instance

export type HydrateConstructor = (
	scope: Scope<unknown>,
	target: Instance
) -> (propertyTable: PropertyTable) -> Instance

-- Is there a sane way to write out this type?
-- ... I sure hope so.

export type ScopedConstructor = (() -> Scope<{}>)
	& (<A>(A & {}) -> Scope<A>)
	& (<A, B>(A & {}, B & {}) -> Scope<A & B>)
	& (<A, B, C>(A & {}, B & {}, C & {}) -> Scope<A & B & C>)
	& (<A, B, C, D>(A & {}, B & {}, C & {}, D & {}) -> Scope<A & B & C & D>)
	& (<A, B, C, D, E>(A & {}, B & {}, C & {}, D & {}, E & {}) -> Scope<A & B & C & D & E>)
	& (<A, B, C, D, E, F>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}) -> Scope<A & B & C & D & E & F>)
	& (<A, B, C, D, E, F, G>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}) -> Scope<A & B & C & D & E & F & G>)
	& (<A, B, C, D, E, F, G, H>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}) -> Scope<A & B & C & D & E & F & G & H>)
	& (<A, B, C, D, E, F, G, H, I>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}) -> Scope<A & B & C & D & E & F & G & H & I>)
	& (<A, B, C, D, E, F, G, H, I, J>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}) -> Scope<A & B & C & D & E & F & G & H & I & J>)
	& (<A, B, C, D, E, F, G, H, I, J, K>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}, K & {}) -> Scope<A & B & C & D & E & F & G & H & I & J & K>)
	& (<A, B, C, D, E, F, G, H, I, J, K, L>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}, K & {}, L & {}) -> Scope<A & B & C & D & E & F & G & H & I & J & K & L>)

export type ContextualConstructor = <T>(defaultValue: T) -> Contextual<T>

export type Fusion = {
	version: Version,
	Contextual: ContextualConstructor,

	doCleanup: (...unknown) -> (),
	scoped: ScopedConstructor,
	deriveScope: <T>(existing: Scope<T>) -> Scope<T>,

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
	Children: SpecialKey,
	Out: (propertyName: string) -> SpecialKey,
	OnEvent: (eventName: string) -> SpecialKey,
	OnChange: (propertyName: string) -> SpecialKey,
	Attribute: (attributeName: string) -> SpecialKey,
	AttributeChange: (attributeName: string) -> SpecialKey,
	AttributeOut: (attributeName: string) -> SpecialKey,
	
}

return nil
