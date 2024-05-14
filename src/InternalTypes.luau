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

-- An object which stores a value scoped in time.
export type Contextual<T> = Types.Contextual<T> & {
	_valuesNow: {[thread]: {value: T}},
	_defaultValue: T
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

return nil