--!strict

--[[
	The entry point for the Instances library.
]]

local PubTypes = require(script.PubTypes)
local restrictRead = require(script.Parent.Core.Utility.restrictRead)

type Instances = {
	version: PubTypes.Version,
	
	New: (className: string) -> ((propertyTable: PubTypes.PropertyTable) -> Instance),
	Hydrate: (target: Instance) -> ((propertyTable: PubTypes.PropertyTable) -> Instance),
	Ref: PubTypes.SpecialKey,
	Cleanup: PubTypes.SpecialKey,
	Children: PubTypes.SpecialKey,
	OnEvent: (eventName: string) -> PubTypes.SpecialKey,
	OnChange: (propertyName: string) -> PubTypes.SpecialKey
}

return restrictRead("Instances", {
	version = {major = 0, minor = 2, isRelease = false},
	
	New = require(script.New),
	Hydrate = require(script.Hydrate),
	Ref = require(script.Ref),
	Out = require(script.Out),
	Cleanup = require(script.Cleanup),
	Children = require(script.Children),
	OnEvent = require(script.OnEvent),
	OnChange = require(script.OnChange)
}) :: Instances