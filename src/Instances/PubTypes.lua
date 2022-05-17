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

-- A task which can be accepted for cleanup.
export type Task =
	Instance |
RBXScriptConnection |
() -> () |
{destroy: (any) -> ()} |
{Destroy: (any) -> ()} |
{Task}

-- Script-readable version information.
export type Version = PubTypes.Version

--[[
	Generic reactive graph types
]]

-- An object which stores a piece of reactive state.
export type StateObject<T> = PubTypes.StateObject<T>

-- Either a constant value of type T, or a state object containing type T.
export type CanBeState<T> = PubTypes.CanBeState<T>

--[[
	Instance related types
]]

-- A semi-weak instance reference.
export type SemiWeakRef = {
	type: string, -- replace with "SemiWeakRef" when Luau supports singleton types
	instance: Instance?
}

-- Denotes children instances in an instance or component's property table.
export type SpecialKey = {
	type: string, -- replace with "SpecialKey" when Luau supports singleton types
	kind: string,
	stage: string, -- replace with "self" | "descendants" | "ancestor" | "observer" when Luau supports singleton types
	apply: (SpecialKey, value: any, applyTo: SemiWeakRef, cleanupTasks: {Task}) -> ()
}

-- A collection of instances that may be parented to another instance.
export type Children = Instance | StateObject<Children> | {[any]: Children}

-- A table that defines an instance's properties, handlers and children.
export type PropertyTable = {[string | SpecialKey]: any}

return nil