--[[
	Stores Luau type definitions shared across scripts in Fusion.
]]

export type Set<T> = {[T]: any}

export type State<T> = {
  get: (State<T>, asDependency: boolean?) -> T,
  set: (State<T>, newValue: any, force: boolean?) -> ()
}

export type StateOrValue<T> = State<T> | T

export type Computed<T> = {
  get: (Computed<T>, asDependency: boolean?) -> T,
  update: (Computed<T>) -> boolean
}

export type Compat = {
  update: (Compat) -> boolean,
  onChange: (Compat, callback: () -> ()) -> ()
}

export type Symbol = {
	type: string,
	name: string,
	key: string?
}

export type Error = {
	raw: string,
	message: string,
	trace: string
}

export type Dependency<T> = State<T> & {
	dependentSet: Set<Dependent<any>>
}

export type Dependent<T> = State<T> & {
	update: (Dependent<T>) -> boolean,
	dependencySet: Set<Dependency<any>>
}

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

export type Tween<T> = {
	get: (Tween<T>, asDependency: boolean?) -> State<T>,
	update: (Tween<T>) -> (),
	-- Uncomment when ENABLE_PARAM_SETTERS is enabled
	-- setTweenInfo: (Tween<T>, newTweenInfo: TweenInfo) -> ()
}

export type Spring<T> = {
	get: (Spring<T>, asDependency: boolean?) -> any,
	update: (Spring<T>) -> (),
	-- Uncomment when ENABLE_PARAM_SETTERS is enabled
	-- setDamping: (Spring<T>, damping: number) -> (),
	-- setSpeed: (Spring<T>, speed: number) -> (),
	-- setPosition: (Spring<T>, newValue: Animatable) -> (),
	-- setVelocity: (Spring<T>, newValue: Animatable) -> (),
	-- addVelocity: (Spring<T>, deltaValue: Animatable) -> ()
}

return nil