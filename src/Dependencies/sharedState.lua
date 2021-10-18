--!strict

--[[
	Stores shared state for dependency management functions.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)

return {
	-- The set where used dependencies should be saved to.
	dependencySet = nil :: Types.Set<Types.Dependency>?,

	-- A stack of sets where newly created dependencies should be stored.
	initialisedStack = {} :: {Types.Set<Types.Dependency>},
	initialisedStackSize = 0
}