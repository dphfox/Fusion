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

--[[
	Specific reactive graph types
]]

-- A state object whose value can be set at any time by the user.
export type Value<T> = PubTypes.Value<T>

-- A state object whose value is derived from other objects using a callback.
export type ForPairs<KO, VO> = StateObject<{ [KO]: VO }> & Dependent & {
	-- kind: "ForPairs" (add this when Luau supports singleton types)
}
-- A state object whose value is derived from other objects using a callback.
export type ForKeys<KO, V> = StateObject<{ [KO]: V }> & Dependent & {
	-- kind: "ForKeys" (add this when Luau supports singleton types)
}
-- A state object whose value is derived from other objects using a callback.
export type ForValues<K, VO> = StateObject<{ [K]: VO }> & Dependent & {
	-- kind: "ForKeys" (add this when Luau supports singleton types)
}

-- An object which can listen for updates on another state object.
export type Observer = Dependent & {
	-- kind: "Observer" (add this when Luau supports singleton types)
	onChange: (Observer, callback: () -> ()) -> (() -> ())
}

return nil