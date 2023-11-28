--!strict

--[[
	The entry point for the Fusion library.
]]

local PubTypes = require(script.PubTypes)
local External = require(script.External)
local restrictRead = require(script.Utility.restrictRead)

export type Symbol  = PubTypes.Symbol 
export type Animatable = PubTypes.Animatable
export type Task = PubTypes.Task
export type Scope<Constructors> = PubTypes.Scope<Constructors>
export type Version = PubTypes.Version
export type Dependency = PubTypes.Dependency
export type Dependent = PubTypes.Dependent
export type StateObject<T> = PubTypes.StateObject<T>
export type CanBeState<T> = PubTypes.CanBeState<T>
export type Use = PubTypes.Use
export type Value<T> = PubTypes.Value<T>
export type Computed<T> = PubTypes.Computed<T>
export type For<KO, VO> = PubTypes.For<KO, VO>
export type Observer = PubTypes.Observer
export type Tween<T> = PubTypes.Tween<T>
export type Spring<T> = PubTypes.Spring<T>
export type SpecialKey = PubTypes.SpecialKey
export type Children = PubTypes.Children
export type PropertyTable = PubTypes.PropertyTable

-- Down the line, this will be conditional based on whether Fusion is being
-- compiled for Roblox.
do
	local RobloxExternal = require(script.RobloxExternal)
	External.setExternalScheduler(RobloxExternal)
end

local Fusion = restrictRead("Fusion", {
	version = {major = 0, minor = 3, isRelease = false},

	cleanup = require(script.Memory.legacyCleanup),
	doCleanup = require(script.Memory.doCleanup),
	doNothing = require(script.Memory.doNothing),
	scoped = require(script.Memory.scoped),
	deriveScope = require(script.Memory.deriveScope),
	
	peek = require(script.State.peek),
	Value = require(script.State.Value),
	Computed = require(script.State.Computed),
	ForPairs = require(script.State.ForPairs),
	ForKeys = require(script.State.ForKeys),
	ForValues = require(script.State.ForValues),
	Observer = require(script.State.Observer),

	Tween = require(script.Animation.Tween),
	Spring = require(script.Animation.Spring),

	New = require(script.Instances.New),
	Hydrate = require(script.Instances.Hydrate),

	Ref = require(script.Instances.Ref),
	Out = require(script.Instances.Out),
	Cleanup = require(script.Instances.Cleanup),
	Children = require(script.Instances.Children),
	OnEvent = require(script.Instances.OnEvent),
	OnChange = require(script.Instances.OnChange),
	Attribute = require(script.Instances.Attribute),
	AttributeChange = require(script.Instances.AttributeChange),
	AttributeOut = require(script.Instances.AttributeOut)
}) :: PubTypes.Fusion

return Fusion
