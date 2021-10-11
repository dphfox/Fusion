--[[
	Stores Luau type definitions shared across scripts in Fusion.
]]

export type Set<T> = {[T]: any}

export type State<T> = {get: (State<T>) -> T}
export type StateOrValue<T> = State<T> | T

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

return nil