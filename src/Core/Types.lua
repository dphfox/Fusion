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

-- A symbol that represents the absence of a value.
export type None = PubTypes.Symbol & {
	-- name: "None" (add this when Luau supports singleton types)
}

-- Stores useful information about Luau errors.
export type Error = {
	type: string, -- replace with "Error" when Luau supports singleton types
	raw: string,
	message: string,
	trace: string
}

--[[
	Specific reactive graph types
]]

-- A state object whose value can be set at any time by the user.
export type State<T> = PubTypes.Value<T> & {
	_value: T
}

-- A state object whose value is derived from other objects using a callback.
export type Computed<T> = PubTypes.Computed<T> & {
	_oldDependencySet: Set<PubTypes.Dependency>,
	_callback: () -> T,
	_value: T
}

return nil