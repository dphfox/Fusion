--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Stores common public-facing type information for Fusion APIs.
]]

export type Error = {
	type: "Error",
	raw: string,
	message: string,
	trace: string,
	context: string?
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
	{destroy: (unknown) -> ()} |
	{Destroy: (unknown) -> ()} |
	{Task}

-- A scope of tasks to clean up.
export type Scope<Constructors = any> = {Task} & Constructors

-- An object which uses a scope to dictate how long it lives.
export type ScopedObject = {
	scope: Scope<unknown>?,
	oldestTask: unknown
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

-- A graph object which can have dependencies and dependencies.
export type GraphObject = ScopedObject & {
	createdAt: number,
	dependencySet: {[GraphObject]: unknown},
	dependentSet: {[GraphObject]: unknown},
	lastChange: number?,
	timeliness: "lazy" | "eager",
	validity: "valid" | "invalid" | "busy",
	_evaluate: (GraphObject) -> boolean
}

-- An object which stores a piece of reactive state.
export type StateObject<T> = GraphObject & {
	type: "State",
	kind: string,
	_EXTREMELY_DANGEROUS_usedAsValue: T
}

-- Passing values of this type to `Use` returns `T`.
export type UsedAs<T> = StateObject<T> | T

-- Function signature for use callbacks.
export type Use = <T>(target: UsedAs<T>) -> T

-- A state object whose value can be set at any time by the user.
export type Value<T, S = T> = StateObject<T> & {
	kind: "State",
	timeliness: "lazy",
 	set: (Value<T, S>, newValue: S, force: boolean?) -> S,
	____phantom_setType: (never) -> S -- phantom data so this contains S
}
export type ValueConstructor = <T>(
	scope: Scope<unknown>,
	initialValue: T
) -> Value<T, any>

-- A state object whose value is derived from other objects using a callback.
export type Computed<T> = StateObject<T> & {
	kind: "Computed",
	timeliness: "lazy"
}
export type ComputedConstructor = <T, S>(
	scope: S & Scope<unknown>,
	callback: (Use, S) -> T
) -> Computed<T>

-- A state object which maps over keys and/or values in another table.
export type For<KO, VO> = StateObject<{[KO]: VO}>  & {
	kind: "For"
}
export type ForPairsConstructor =  <KI, KO, VI, VO, S>(
	scope: S & Scope<unknown>,
	inputTable: UsedAs<{[KI]: VI}>,
	processor: (Use, S, key: KI, value: VI) -> (KO, VO)
) -> For<KO, VO>
export type ForKeysConstructor =  <KI, KO, V, S>(
	scope: S & Scope<unknown>,
	inputTable: UsedAs<{[KI]: V}>,
	processor: (Use, S, key: KI) -> KO
) -> For<KO, V>
export type ForValuesConstructor =  <K, VI, VO, S>(
	scope: S & Scope<unknown>,
	inputTable: UsedAs<{[K]: VI}>,
	processor: (Use, S, value: VI) -> VO
) -> For<K, VO>

-- An object which can listen for updates on another state object.
export type Observer = GraphObject & {
	type: "Observer",
	timeliness: "eager",
	onChange: (Observer, callback: () -> ()) -> (() -> ()),
	onBind: (Observer, callback: () -> ()) -> (() -> ())
}
export type ObserverConstructor = (
	scope: Scope<unknown>,
	watching: unknown
) -> Observer

-- A state object which follows another state object using tweens.
export type Tween<T> = StateObject<T> & {
	kind: "Tween"
}
export type TweenConstructor = <T>(
	scope: Scope<unknown>,
	goalState: UsedAs<T>,
	tweenInfo: UsedAs<TweenInfo>?
) -> Tween<T>

-- A state object which follows another state object using spring simulation.
export type Spring<T> = StateObject<T>  & {
	kind: "Spring",
	setPosition: (Spring<T>, newPosition: T) -> (),
	setVelocity: (Spring<T>, newVelocity: T) -> (),
	addVelocity: (Spring<T>, deltaVelocity: T) -> ()
}
export type SpringConstructor = <T>(
	scope: Scope<unknown>,
	goalState: UsedAs<T>,
	speed: UsedAs<number>?,
	damping: UsedAs<number>?
) -> Spring<T>

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

export type DeriveScopeConstructor = (<S>(Scope<S>) -> Scope<S>)
	& (<S, A>(Scope<S>, A & {}) -> Scope<S & A>)
	& (<S, A, B>(Scope<S>, A & {}, B & {}) -> Scope<S & A & B>)
	& (<S, A, B, C>(Scope<S>, A & {}, B & {}, C & {}) -> Scope<S & A & B & C>)
	& (<S, A, B, C, D>(Scope<S>, A & {}, B & {}, C & {}, D & {}) -> Scope<S & A & B & C & D>)
	& (<S, A, B, C, D, E>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}) -> Scope<S & A & B & C & D & E>)
	& (<S, A, B, C, D, E, F>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}) -> Scope<S & A & B & C & D & E & F>)
	& (<S, A, B, C, D, E, F, G>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}) -> Scope<S & A & B & C & D & E & F & G>)
	& (<S, A, B, C, D, E, F, G, H>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}) -> Scope<S & A & B & C & D & E & F & G & H>)
	& (<S, A, B, C, D, E, F, G, H, I>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}) -> Scope<S & A & B & C & D & E & F & G & H & I>)
	& (<S, A, B, C, D, E, F, G, H, I, J>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}) -> Scope<S & A & B & C & D & E & F & G & H & I & J>)
	& (<S, A, B, C, D, E, F, G, H, I, J, K>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}, K & {}) -> Scope<S & A & B & C & D & E & F & G & H & I & J & K>)
	& (<S, A, B, C, D, E, F, G, H, I, J, K, L>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}, K & {}, L & {}) -> Scope<S & A & B & C & D & E & F & G & H & I & J & K & L>)

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

export type Safe = <Success, Fail>(
	callbacks: {
		try: () -> Success,
		fallback: (err: unknown) -> Fail
	}
) -> Success | Fail

export type Fusion = {
	version: Version,
	Contextual: ContextualConstructor,
	Safe: Safe,

	doCleanup: (Task) -> (),
	scoped: ScopedConstructor,
	deriveScope: DeriveScopeConstructor,
	innerScope: DeriveScopeConstructor,

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

	Child: ({Child}) -> Child,
	Children: SpecialKey,
	Out: (propertyName: string) -> SpecialKey,
	OnEvent: (eventName: string) -> SpecialKey,
	OnChange: (propertyName: string) -> SpecialKey,
	Attribute: (attributeName: string) -> SpecialKey,
	AttributeChange: (attributeName: string) -> SpecialKey,
	AttributeOut: (attributeName: string) -> SpecialKey,
}

export type ExternalProvider = {
	policies: {
		allowWebLinks: boolean
	},

	logErrorNonFatal: (
		errorString: string
	) -> (),
	logWarn: (
		errorString: string
	) -> (),
	
	doTaskImmediate: (
		resume: () -> ()
	) -> (),
	doTaskDeferred: (
		resume: () -> ()
	) -> (),
	startScheduler: () -> (),
	stopScheduler: () -> ()
}

export type ExternalDebugger = {
	startDebugging: () -> (),
	stopDebugging: () -> (),

	trackScope: (
		scope: Scope<unknown>
	) -> (),
	untrackScope: (
		scope: Scope<unknown>
	) -> ()
}

return nil
