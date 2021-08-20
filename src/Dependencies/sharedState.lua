--[[
	Stores shared state for dependency management functions.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)

type SharedState = {
	dependencySet: Types.Set<Types.Dependency<any>>?,

	initialisedStack: {Types.Set<Types.Dependency<any>>},
	initialisedStackSize: number
}

local sharedState: SharedState = {
	-- The set where used dependencies should be saved to.
	dependencySet = nil,

	-- A stack of sets where newly created dependencies should be stored.
	initialisedStack = {},
	initialisedStackSize = 0
}

return sharedState