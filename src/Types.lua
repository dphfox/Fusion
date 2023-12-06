--!strict

--[[
	Stores common type information used internally.

	These types may be used internally so Fusion code can type-check, but
	should never be exposed to public users, as these definitions are fair game
	for breaking changes.
]]

local Package = script.Parent
local PubTypes = require(Package.PubTypes)

type Set<T> = {[T]: any}

--[[
	General use types
]]

-- Stores useful information about Luau errors.
export type Error = {
	type: string, -- replace with "Error" when Luau supports singleton types
	raw: string,
	message: string,
	trace: string
}

--[[
	Generic reactive graph types
]]

export type StateObject<T> = PubTypes.StateObject<T> & {
	_peek: (StateObject<T>) -> T
}

--[[
	Specific reactive graph types
]]

-- A state object whose value can be set at any time by the user.
export type State<T> = PubTypes.Value<T> & {
	_value: T
}

-- A state object whose value is derived from other objects using a callback.
export type Computed<T, S> = PubTypes.Computed<T> & {
	scope: PubTypes.Scope<S>,
	_oldDependencySet: Set<PubTypes.Dependency>,
	_processor: (PubTypes.Use, PubTypes.Scope<S>) -> T,
	_value: T,
	_innerScope: PubTypes.Scope<S>?
}

-- A state object which maps over keys and/or values in another table.
export type For<KI, KO, VI, VO> = PubTypes.For<KO, VO> & {
	_processor: (
		PubTypes.StateObject<{key: KI, value: VI}>,
		PubTypes.Scope<any>
	) -> (PubTypes.StateObject<{key: KO?, value: VO?}>),
	_inputTable: PubTypes.CanBeState<{[KI]: VI}>,
	_existingInputTable: {[KI]: VI}?,
	_existingOutputTable: {[KO]: VO},
	_existingProcessors: {[ForProcessor]: true},
	_newOutputTable: {[KO]: VO},
	_newProcessors: {[ForProcessor]: true},
	_remainingPairs: {[KI]: {[VI]: true}}
}
type ForProcessor = {
	inputPair: PubTypes.Value<{key: any, value: any}>,
	outputPair: PubTypes.StateObject<{key: any, value: any}>,
	cleanupTask: any
}

-- A state object which follows another state object using tweens.
export type Tween<T> = PubTypes.Tween<T> & {
	_goalState: State<T>,
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
export type Spring<T> = PubTypes.Spring<T> & {
	_speed: PubTypes.CanBeState<number>,
	_damping: PubTypes.CanBeState<number>,
	_goalState: State<T>,
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
export type Observer = PubTypes.Observer & {
	_changeListeners: Set<() -> ()>,
	_numChangeListeners: number
}

return nil