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
	type: string, -- replace with "Symbol" when Luau supports singleton types
	name: string
}

-- PubTypes that can be expressed as vectors of numbers, and so can be animated.
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
	type: string, -- replace with "State" when Luau supports singleton types
	kind: string,
	get: (StateObject<T>, asDependency: boolean?) -> T
}

-- Either a constant value of type T, or a state object containing type T.
export type CanBeState<T> = StateObject<T> | T

--[[
	Specific reactive graph types
]]

-- A state object whose value can be set at any time by the user.
export type Value<T> = StateObject<T> & {
	-- kind: "State" (add this when Luau supports singleton types)
 	set: (Value<T>, newValue: any, force: boolean?) -> ()
}

-- A state object whose value is derived from other objects using a callback.
export type Computed<T> = StateObject<T> & Dependent & {
	-- kind: "Computed" (add this when Luau supports singleton types)
}

-- A state object whose value is derived from other objects using a callback.
export type ComputedPairs<K, V> = StateObject<{[K]: V}> & Dependent & {
	-- kind: "ComputedPairs" (add this when Luau supports singleton types)
}

-- A state object which follows another state object using tweens.
export type Tween<T> = StateObject<T> & Dependent & {
	-- kind: "Tween" (add this when Luau supports singleton types)
}

-- A state object which follows another state object using spring simulation.
export type Spring<T> = StateObject<T> & Dependent & {
	-- kind: "Spring" (add this when Luau supports singleton types)
	-- Uncomment when ENABLE_PARAM_SETTERS is enabled
	-- setPosition: (Spring<T>, newValue: Animatable) -> (),
	-- setVelocity: (Spring<T>, newValue: Animatable) -> (),
	-- addVelocity: (Spring<T>, deltaValue: Animatable) -> ()
}

-- An object which can listen for updates on another state object.
export type Observer = Dependent & {
	-- kind: "Observer" (add this when Luau supports singleton types)
  	onChange: (Observer, callback: () -> ()) -> (() -> ())
}

--[[
	Property table types
]]

-- Denotes children instances in an instance or component's property table.
export type ChildrenKey = Symbol & {
	-- name: "Children" (add this when Luau supports singleton types)
}

-- Denotes reference instances in an instance or component's property table.
export type RefKey = Symbol & {
	-- name: "Ref" (add this when Luau supports singleton types)
}

-- Denotes property change handlers in an instance's property table.
export type OnChangeKey = Symbol & {
	-- name: "OnChange" (add this when Luau supports singleton types)
	key: string
}

-- Denotes event  handlers in an instance's property table.
export type OnEventKey = Symbol & {
	-- name: "OnEvent" (add this when Luau supports singleton types)
	key: string
}

-- A collection of instances that may be parented to another instance.
export type Children = Instance | StateObject<Children> | {[any]: Children}

-- A table that defines an instance's properties, handlers and children.
-- FUTURE: Typed Luau is not advanced enough to express this type in full
-- specificity yet, so we have to settle for some runtime type checking here.
-- In psuedo-Luau, this definition should be akin to the following:
-- export type PropertyTable<ClassName> = {
--     [ClassName::Property]: CanBeState<Property::Value>
--     [OnEventKey]: (any...) -> (),
--     [OnChangeKey]: (any) -> (),
--     [ChildrenKey]: Children
--     [RefKey]: Value
-- }
export type PropertyTable = {
	[string | OnEventKey | OnChangeKey | ChildrenKey | RefKey]: any
}



return nil