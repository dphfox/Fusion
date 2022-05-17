--!strict

--[[
	The entry point for the Motion library.
]]

local PubTypes = require(script.PubTypes)
local restrictRead = require(script.Parent.Core.Utility.restrictRead)

type StateObject<T> = PubTypes.StateObject<T>
export type Tween<T> = PubTypes.Tween<T>
export type Spring<T> = PubTypes.Spring<T>

type Motion = {
	version: PubTypes.Version,

	Tween: <T>(goalState: StateObject<T>, tweenInfo: TweenInfo?) -> Tween<T>,
	Spring: <T>(goalState: StateObject<T>, speed: number?, damping: number?) -> Spring<T>
}

return restrictRead("Motion", {
	version = {major = 0, minor = 2, isRelease = false},
	
	Spring = require(script.Spring),
	Tween = require(script.Tween)
}) :: Motion