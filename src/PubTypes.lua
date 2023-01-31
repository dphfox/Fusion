--!strict

--[[
	Stores common public-facing type information for Fusion APIs.
]]

type Set<T> = {[T]: any}

-- Fusion / State /

export type CanBeState<T> = StateObject<T> | T
export type Computed<T, M> = StateObject<T> & Dependent & {
	kind: "Computed"
}
export type cleanup = (...any) -> ()
export type Dependency = {
	dependentSet: Set<Dependent>
}
export type Dependent = {
	update: (Dependent) -> boolean,
	dependencySet: Set<Dependency>
}
export type doNothing = (...any) -> ()
export type ForKeys<KI, KO, V, M> = StateObject<{ [KO]: V }> & Dependent & {
	kind: "ForKeys"
}
export type ForPairs<KI, VI, KO, VO, M> = StateObject<{ [KO]: VO }> & Dependent & {
	kind: "ForPairs"
}
export type ForValues<K, VI, VO, M> = StateObject<{ [K]: VO }> & Dependent & {
	kind: "ForValues"
}
export type Observer = Dependent & {
	kind: "Observer",
  	onChange: (Observer, callback: () -> ()) -> (() -> ())
}
export type StateObject<T> = Dependency & {
	type: "State",
	kind: string,
	get: (StateObject<T>, asDependency: boolean?) -> T
}
export type Value<T> = StateObject<T> & {
	kind: "State",
 	set: (Value<T>, newValue: any, force: boolean?) -> ()
}

-- Fusion / Instances /

export type Child = Instance | {[any]: Child} | StateObject<Child>
export type Children = SpecialKey
export type Cleanup = SpecialKey
export type Component = (props: {[any]: any}) -> Child
export type Hydrate = (target: Instance) -> Component
export type New = (className: string) -> Component
export type OnChange = SpecialKey
export type OnEvent = SpecialKey
export type Out = SpecialKey
export type Ref = SpecialKey
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
	kind: "Tween"
}
export type Spring<T> = StateObject<T> & Dependent & {
	kind: "Spring",
	setPosition: (Spring<T>, newPosition: T) -> (),
	setVelocity: (Spring<T>, newVelocity: T) -> (),
	addVelocity: (Spring<T>, deltaVelocity: T) -> ()
}

return nil