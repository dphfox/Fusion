--!strict

--[[
	The entry point for the Core library.
]]

local PubTypes = require(script.PubTypes)
local restrictRead = require(script.Utility.restrictRead)

export type Value<T> = PubTypes.Value<T>
export type Computed<T> = PubTypes.Computed<T>

type Core = {
	version: PubTypes.Version,

	Value: <T>(initialValue: T) -> Value<T>,
	Computed: <T>(callback: () -> T) -> Computed<T>
}

return restrictRead("Core", {
	version = {major = 0, minor = 2, isRelease = false},
	
	Computed = require(script.Computed),
	Value = require(script.Value)
}) :: Core