--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Stores common type information used internally.

	These types may be used internally so Fusion code can type-check, but
	should never be exposed to public users, as these definitions are fair game
	for breaking changes.
]]

local Package = script.Parent
local Types = require(Package.Types)

--[[
	General use types
]]

-- An object which stores a value scoped in time.
export type Contextual<T> = Types.Contextual<T> & {
	_valuesNow: {[thread]: {value: T}},
	_defaultValue: T
}

--[[
	Generic reactive graph types
]]

export type StateObject<T> = Types.StateObject<T> & {
	_peek: (StateObject<T>) -> T
}

--[[
	Specific reactive graph types
]]

-- A state object whose value can be set at any time by the user.
export type Value<T, S = T> = Types.Value<T, S> & {
	_value: S
}

-- A state object whose value is derived from other objects using a callback.
export type Computed<T, S> = Types.Computed<T> & {
	scope: Types.Scope<S>?,
	_oldDependencySet: {[Types.Dependency]: unknown},
	_processor: (Types.Use, Types.Scope<S>) -> T,
	_value: T,
	_innerScope: Types.Scope<S>?
}

-- A state object which maps over keys and/or values in another table.
export type For<KI, KO, VI, VO, S> = Types.For<KO, VO> & {
	scope: Types.Scope<S>?,
	_processor: (
		Types.Scope<S>,
		Types.StateObject<{key: KI, value: VI}>
	) -> (Types.StateObject<{key: KO?, value: VO?}>),
	_inputTable: Types.UsedAs<{[KI]: VI}>,
	_existingInputTable: {[KI]: VI}?,
	_existingOutputTable: {[KO]: VO},
	_existingProcessors: {[ForProcessor]: true},
	_newOutputTable: {[KO]: VO},
	_newProcessors: {[ForProcessor]: true},
	_remainingPairs: {[KI]: {[VI]: true}}
}
type ForProcessor = {
	inputPair: Types.Value<{key: unknown, value: unknown}>,
	outputPair: Types.StateObject<{key: unknown, value: unknown}>,
	scope: Types.Scope<unknown>?
}

-- A state object which follows another state object using tweens.
export type Tween<T> = Types.Tween<T> & {
	_goal: Types.UsedAs<T>,
	_tweenInfo: TweenInfo,
	_prevValue: T,
	_nextValue: T,
	_currentValue: T,
	_currentTweenInfo: TweenInfo,
	_currentTweenDuration: number,
	_currentTweenStartTime: number,
	_currentlyAnimating: boolean
}

-- A state object which follows another state object using spring simulation.
export type Spring<T> = Types.Spring<T> & {
	_speed: Types.UsedAs<number>,
	_damping: Types.UsedAs<number>,
	_goal: Types.UsedAs<T>,
	_goalValue: T,

	_currentType: string,
	_currentValue: T,
	_currentSpeed: number,
	_currentDamping: number,

	_springPositions: {number},
	_springGoals: {number},
	_springVelocities: {number},

	_lastSchedule: number,
	_startDisplacements: {number},
	_startVelocities: {number}
}

-- An object which can listen for updates on another state object.
export type Observer = Types.Observer & {
	_changeListeners: {[{}]: () -> ()},
	_numChangeListeners: number
}

return nil