--!strict

--[[
	Stores shared state for dependency management functions.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)

-- The set where used dependencies should be saved to.
local dependencySet: Types.Set<Types.Dependency>? = nil

-- A stack of sets where newly created dependencies should be stored.
local initialisedStack: {Types.Set<Types.Dependency>} = {}
local initialisedStackSize = 0

return {
	dependencySet = dependencySet,
	initialisedStack = initialisedStack,
	initialisedStackSize = initialisedStackSize
}