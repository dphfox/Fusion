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
export type Dependency = {
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
	kind: string
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
type ValueConstructor = <T, S>(
	scope: Scope<S>,
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
type ForKeysConstructor =  <KI, KO, V, M>(
	inputTable: CanBeState<{[KI]: V}>,
	processor: (Use, KI) -> (KO, M?),
	destructor: (KO, M?) -> ()?
) -> For<KO, V>
type ForValuesConstructor =  <K, VI, VO, M>(
	inputTable: CanBeState<{[K]: VI}>,
	processor: (Use, VI) -> (VO, M?),
	destructor: (VO, M?) -> ()?
) -> For<K, VO>


-- A state object which follows another state object using tweens.
export type Tween<T> = StateObject<T> & Dependent & {
	kind: "Tween",
	destroy: () -> ()
}

-- A state object which follows another state object using spring simulation.
export type Spring<T> = StateObject<T> & Dependent & {
	kind: "Spring",
	setPosition: (Spring<T>, newPosition: Animatable) -> (),
	setVelocity: (Spring<T>, newVelocity: Animatable) -> (),
	addVelocity: (Spring<T>, deltaVelocity: Animatable) -> (),
	destroy: () -> ()
}

-- An object which can listen for updates on another state object.
export type Observer = Dependent & {
	kind: "Observer",
	onChange: (Observer, callback: () -> ()) -> (() -> ()),
	destroy: () -> ()
}

--[[
	Instance related types
]]

-- Denotes children instances in an instance or component's property table.
export type SpecialKey = {
	type: "SpecialKey",
	kind: string,
	stage: "self" | "descendants" | "ancestor" | "observer",
	apply: (SpecialKey, value: any, applyTo: Instance, cleanupTasks: {Task}) -> ()
}

-- A collection of instances that may be parented to another instance.
export type Children = Instance | StateObject<Children> | {[any]: Children}

-- A table that defines an instance's properties, handlers and children.
export type PropertyTable = {[string | SpecialKey]: any}

export type Fusion = {
	version: Version,

	New: (className: string) -> ((propertyTable: PropertyTable) -> Instance),
	Hydrate: (target: Instance) -> ((propertyTable: PropertyTable) -> Instance),
	Ref: SpecialKey,
	Cleanup: SpecialKey,
	Children: SpecialKey,
	Out: (propertyName: string) -> SpecialKey,
	OnEvent: (eventName: string) -> SpecialKey,
	OnChange: (propertyName: string) -> SpecialKey,
	Attribute: (attributeName: string) -> SpecialKey,
	AttributeChange: (attributeName: string) -> SpecialKey,
	AttributeOut: (attributeName: string) -> SpecialKey,

	Value: ValueConstructor,
	Computed: ComputedConstructor,
	ForPairs: <KI, KO, VI, VO, M>(inputTable: CanBeState<{[KI]: VI}>, processor: (Use, KI, VI) -> (KO, VO, M?), destructor: (KO, VO, M?) -> ()?) -> For<KO, VO>,
	ForKeys: <KI, KO, V, M>(inputTable: CanBeState<{[KI]: V}>, processor: (Use, KI) -> (KO, M?), destructor: (KO, M?) -> ()?) -> For<KO, V>,
	ForValues: <K, VI, VO, M>(inputTable: CanBeState<{[K]: VI}>, processor: (Use, VI) -> (VO, M?), destructor: (VO, M?) -> ()?) -> For<K, VO>,
	Observer: (watchedState: StateObject<any>) -> Observer,

	Tween: <T>(goalState: StateObject<T>, tweenInfo: TweenInfo?) -> Tween<T>,
	Spring: <T>(goalState: StateObject<T>, speed: CanBeState<number>?, damping: CanBeState<number>?) -> Spring<T>,

	doCleanup: (...any) -> (),
	doNothing: (...any) -> (),
	peek: Use
}

return nil