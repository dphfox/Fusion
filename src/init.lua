--!strict
--!nolint LocalShadow

--[[
	The entry point for the Fusion library.
]]

local Types = require(script.Types)
local External = require(script.External)

export type Animatable = Types.Animatable
export type Task = Types.Task
export type Scope<Constructors> = Types.Scope<Constructors>
export type Version = Types.Version
export type Dependency = Types.Dependency
export type Dependent = Types.Dependent
export type StateObject<T> = Types.StateObject<T>
export type CanBeState<T> = Types.CanBeState<T>
export type Use = Types.Use
export type Value<T> = Types.Value<T>
export type Computed<T> = Types.Computed<T>
export type For<KO, VO> = Types.For<KO, VO>
export type Observer = Types.Observer
export type Tween<T> = Types.Tween<T>
export type Spring<T> = Types.Spring<T>
export type SpecialKey = Types.SpecialKey
export type Children = Types.Children
export type PropertyTable = Types.PropertyTable

-- Down the line, this will be conditional based on whether Fusion is being
-- compiled for Roblox.
do
	local RobloxExternal = require(script.RobloxExternal)
	External.setExternalScheduler(RobloxExternal)
end

local Fusion: Types.Fusion = {
	version = {major = 0, minor = 3, isRelease = false},

	cleanup = require(script.Memory.legacyCleanup),
	doCleanup = require(script.Memory.doCleanup),
	scoped = require(script.Memory.scoped),
	deriveScope = require(script.Memory.deriveScope),
	
	peek = require(script.State.peek),
	Value = require(script.State.Value),
	Computed = require(script.State.Computed),
	ForPairs = require(script.State.ForPairs) :: Types.ForPairsConstructor,
	ForKeys = require(script.State.ForKeys) :: Types.ForKeysConstructor,
	ForValues = require(script.State.ForValues) :: Types.ForValuesConstructor,
	Observer = require(script.State.Observer),

	Tween = require(script.Animation.Tween),
	Spring = require(script.Animation.Spring),

	New = require(script.Instances.New),
	Hydrate = require(script.Instances.Hydrate),

	Ref = require(script.Instances.Ref),
	Out = require(script.Instances.Out),
	Children = require(script.Instances.Children),
	OnEvent = require(script.Instances.OnEvent),
	OnChange = require(script.Instances.OnChange),
	Attribute = require(script.Instances.Attribute),
	AttributeChange = require(script.Instances.AttributeChange),
	AttributeOut = require(script.Instances.AttributeOut)
}

return Fusion
