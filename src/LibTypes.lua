--!strict

--[[
	Stores common private type information for Fusion APIs.
	These types may be used internally so Fusion code can type-check, but
	should never be exposed to public users, as these definitions are fair game
	for breaking changes.
]]

local Package = script.Parent
local Types = require(Package.Types)

--[[
	Specific reactive graph types
]]

-- A state object whose value can be set at any time by the user.
export type State<T> = Types.State<T> & {
	_value: T
}

-- A state object whose value is derived from other objects using a callback.
export type Computed<T> = Types.Computed<T> & {
	_oldDependencySet: Types.Set<Types.Dependency>,
	_callback: () -> T,
	_value: T
}

-- A state object whose value is derived from other objects using a callback.
export type ComputedPairs<K, VI, VO> = Types.ComputedPairs<K, VO> & {
	_oldDependencySet: Types.Set<Types.Dependency>,
	_processor: (K, VI) -> VO,
	_destructor: (VO) -> (),
	_inputIsState: boolean,
	_inputTable: Types.StateOrValue<{[K]: VI}>,
	_oldInputTable: {[K]: VI},
	_outputTable: {[K]: VO},
	_oldOutputTable: {[K]: VO},
	_keyData: {[K]: {
		dependencySet: Types.Set<Types.Dependency>,
		oldDependencySet: Types.Set<Types.Dependency>,
		dependencyValues: {[Types.Dependency]: any}
	}}
}

-- A state object which follows another state object using tweens.
export type Tween<T> = Types.Tween<T> & {
	_goalState: State<T>,
	_tweenInfo: TweenInfo,
	_prevValue: T,
	_nextValue: T,
	_currentValue: T,
	_currentTweenInfo: TweenInfo,
	_currentTweenDuration: number,
	_currentTweenStartTime: number
}

-- A state object which follows another state object using spring simulation.
export type Spring<T> = Types.Spring<T> & {
	_speed: Types.StateOrValue<number>,
	_speedIsState: boolean,
	_lastSpeed: number,
	_damping: Types.StateOrValue<number>,
	_dampingIsState: boolean,
	_lastDamping: number,
	_goalState: State<T>,
	_goalValue: T,
	_currentType: string,
	_currentValue: T,
	_springPositions: {number},
	_springGoals: {number},
	_springVelocities: {number}
}

-- An object which can listen for updates on another state object.
export type Compat = Types.Compat & {
	_changeListeners: Types.Set<() -> ()>,
	_numChangeListeners: number
}

return nil