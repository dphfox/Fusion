--!strict

--[[
	Stores Luau type definitions shared across scripts in Fusion.
]]

--[[
	General use types
]]

-- A set collection - keys are the elements of the set. Values are ignored.
export type Set<T> = {[T]: any}

-- A unique symbolic value - can also store a key for variants.
export type Symbol = {
	type: string, -- replace with "Symbol" when Luau supports singleton types
	name: string,
	key: string?
}

-- Stores useful information about Luau errors.
export type Error = {
	raw: string,
	message: string,
	trace: string
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
export type StateOrValue<T> = StateObject<T> | T

--[[
	Specific reactive graph types
]]

-- A state object whose value can be set at any time by the user.
export type State<T> = StateObject<T> & {
	-- kind: "State" (add this when Luau supports singleton types)
 	set: (State<T>, newValue: any, force: boolean?) -> ()
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
export type Compat = Dependent & {
	-- kind: "Compat" (add this when Luau supports singleton types)
  	onChange: (Compat, callback: () -> ()) -> ()
}

return nil