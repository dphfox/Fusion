--!strict

--[[
	Stores common type information used internally.

	These types may be used internally so Fusion code can type-check, but
	should never be exposed to public users, as these definitions are fair game
	for breaking changes.
]]

type Set<T> = {[T]: any}

-- General

export type Symbol = {
	type: "Symbol",
	name: string
}
export type None = Symbol & {
	name: "None"
}
export type Error = {
	type: "Error",
	raw: string,
	message: string,
	trace: string
}

-- Fusion / State /

export type CanBeState<T> = StateObject<T> | T
export type Computed<T, M> = StateObject<T> & Dependent & {
	kind: "Computed",

	_oldDependencySet: Set<Dependency>,
	_callback: () -> T,
	_value: T
}
export type Computed__new<T, M> = (
    processor: () -> (T, M),
    destructor: ((T, M) -> ())?
) -> Computed<T, M>
export type cleanup = Destructor
export type Destructible = Instance | RBXScriptConnection | () -> () |
	{destroy: (any) -> ()} | {Destroy: (any) -> ()} | {Destructible}
export type Destructor = (...Destructible) -> ()
export type Dependency = {
	dependentSet: Set<Dependent>
}
export type Dependent = {
	update: (Dependent) -> boolean,
	dependencySet: Set<Dependency>
}
export type doNothing = Destructor
export type ForKeys<KI, KO, V, M> = StateObject<{ [KO]: V }> & Dependent & {
	kind: "ForKeys",

	_oldDependencySet: Set<Dependency>,
	_processor: (KI) -> (KO),
	_destructor: (KO, M?) -> (),
	_inputIsState: boolean,
	_inputTable: CanBeState<{ [KI]: KO }>,
	_oldInputTable: { [KI]: KO },
	_outputTable: { [KO]: any },
	_keyOIMap: { [KO]: KI },
	_meta: { [KO]: M? },
	_keyData: {
		[KI]: {
			dependencySet: Set<Dependency>,
			oldDependencySet: Set<Dependency>,
			dependencyValues: { [Dependency]: any },
		},
	},
}
export type ForKeys__new<KI, KO, V, M> = (
    input: CanBeState<{[KI]: V}>,
    keyProcessor: (KI, M) -> (KO, M),
    keyDestructor: ((KO, M) -> ())?
) -> ForKeys<KI, KO, V, M>
export type ForPairs<KI, VI, KO, VO, M> = StateObject<{ [KO]: VO }> & Dependent & {
	kind: "ForPairs",

	_oldDependencySet: Set<Dependency>,
	_processor: (KI, VI) -> (KO, VO),
	_destructor: (VO, M?) -> (),
	_inputIsState: boolean,
	_inputTable: CanBeState<{ [KI]: VI }>,
	_oldInputTable: { [KI]: VI },
	_outputTable: { [KO]: VO },
	_oldOutputTable: { [KO]: VO },
	_keyIOMap: { [KI]: KO },
	_meta: { [KO]: M? },
	_keyData: {
		[KI]: {
			dependencySet: Set<Dependency>,
			oldDependencySet: Set<Dependency>,
			dependencyValues: { [Dependency]: any },
		},
	},
}
export type ForPairs__new<KI, VI, KO, VO, M> = (
    input: CanBeState<{[KI]: VI}>,
    pairProcessor: (KI, VI, M) -> (KO, VO, M),
    pairDestructor: ((KO, VO, M) -> ())?
) -> ForPairs<KI, VI, KO, VO, M>
export type ForValues<K, VI, VO, M> = StateObject<{ [K]: VO }> & Dependent & {
	kind: "ForValues",

	_oldDependencySet: Set<Dependency>,
	_processor: (VI) -> (VO),
	_destructor: (VO, M?) -> (),
	_inputIsState: boolean,
	_inputTable: CanBeState<{ [VI]: VO }>,
	_outputTable: { [any]: VI },
	_valueCache: { [VO]: any },
	_oldValueCache: { [VO]: any },
	_meta: { [VO]: M? },
	_valueData: {
		[VI]: {
			dependencySet: Set<Dependency>,
			oldDependencySet: Set<Dependency>,
			dependencyValues: { [Dependency]: any },
		},
	},
}
export type ForValues__new<K, VI, VO, M> = (
    input: CanBeState<{[K]: VI}>,
    valueProcessor: (VI, M) -> (VO, M),
    valueDestructor: ((VO, M) -> ())?
) -> ForValues<K, VI, VO, M>
export type Observer = Dependent & {
	kind: "Observer",
  	onChange: (Observer, callback: () -> ()) -> (() -> ())
}
export type Observer__new = (
    observe: Dependency,

	_changeListeners: Set<() -> ()>,
	_numChangeListeners: number
) -> Observer
export type StateObject<T> = Dependency & {
	type: "State",
	kind: string,
	get: (StateObject<T>, asDependency: boolean?) -> T
}
export type Value<T> = StateObject<T> & {
	kind: "State",
 	set: (Value<T>, newValue: any, force: boolean?) -> ()
}
export type Value__new<T> = (
    initialValue: T
) -> Value<T>

-- Fusion / Instances /

export type Child = Instance | {[any]: Child} | StateObject<Child>
export type Children = SpecialKey & {
	kind: "Children",
	stage: "descendants"
}
export type Cleanup = SpecialKey & {
	kind: "Cleanup",
	stage: "observer"
}
export type Component = (props: {[any]: any}) -> Child
export type Hydrate = (target: Instance) -> Component
export type New = (className: string) -> Component
export type OnChange = SpecialKey & {
	kind: "OnChange",
	stage: "observer"
}
export type OnChange__new = (propertyName: string) -> OnChange
export type OnEvent = SpecialKey & {
	kind: "OnEvent",
	stage: "observer"
}
export type OnEvent__new = (eventName: string) -> OnEvent
export type Out = SpecialKey & {
	kind: "Out",
	stage: "observer"
}
export type Out__new = (propertyName: string) -> OnChange
export type Ref = SpecialKey & {
	kind: "Ref",
	stage: "observer"
}
export type SpecialKey = {
    type: "SpecialKey",
    kind: string,
    stage: "self" | "descendants" | "ancestor" | "observer",
    apply: (
        self: SpecialKey,
        value: any,
        applyTo: Instance,
        cleanupTasks: {Destructible}
    ) -> ()
}

-- Fusion / Animation /

export type Animatable = number | CFrame | Color3 | ColorSequenceKeypoint | DateTime | NumberRange |
	NumberSequenceKeypoint | PhysicalProperties | Ray | Rect | Region3 | Region3int16 | UDim | UDim2 | Vector2 |
	Vector2int16 | Vector3 | Vector3int16
export type Tween<T> = StateObject<T> & Dependent & {
	kind: "Tween",

	_goalState: Value<T>,
	_tweenInfo: TweenInfo,
	_prevValue: T,
	_nextValue: T,
	_currentValue: T,
	_currentTweenInfo: TweenInfo,
	_currentTweenDuration: number,
	_currentTweenStartTime: number,
	_currentlyAnimating: boolean
}
export type Tween__new<T> = (
    goal: StateObject<T>,
    tweenInfo: CanBeState<TweenInfo>?
) -> Tween<T>
export type Spring<T> = StateObject<T> & Dependent & {
	kind: "Spring",
	setPosition: (Spring<T>, newPosition: T) -> (),
	setVelocity: (Spring<T>, newVelocity: T) -> (),
	addVelocity: (Spring<T>, deltaVelocity: T) -> (),

	_speed: CanBeState<number>,
	_speedIsState: boolean,
	_lastSpeed: number,
	_damping: CanBeState<number>,
	_dampingIsState: boolean,
	_lastDamping: number,
	_goalState: Value<T>,
	_goalValue: T,
	_currentType: string,
	_currentValue: T,
	_springPositions: {number},
	_springGoals: {number},
	_springVelocities: {number},
	_lastSchedule: number,
	_startDisplacements: {number},
	_startVelocities: {number},
	_currentDamping: number,
	_currentSpeed: number
}
export type Spring__new<T> = (
    goal: StateObject<T>,
    speed: CanBeState<number>?,
    damping: CanBeState<number>?
) -> Spring<T>

return nil