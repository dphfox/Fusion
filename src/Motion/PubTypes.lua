--!strict

local Package = script.Parent.Parent
local PubTypes = require(Package.Core.PubTypes)

--[[
	Stores common public-facing type information for Fusion APIs.
]]

type Set<T> = {[T]: any}

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

-- Script-readable version information.
export type Version = PubTypes.Version

--[[
	Generic reactive graph types
]]

-- A graph object which can have dependents.
export type Dependency = PubTypes.Dependency

-- A graph object which can have dependencies.
export type Dependent = PubTypes.Dependent

-- An object which stores a piece of reactive state.
export type StateObject<T> = PubTypes.StateObject<T>

-- Either a constant value of type T, or a state object containing type T.
export type CanBeState<T> = PubTypes.CanBeState<T>

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

--[[
	Specific reactive graph types
]]

-- A state object whose value can be set at any time by the user.
export type Value<T> = PubTypes.Value<T>

return nil