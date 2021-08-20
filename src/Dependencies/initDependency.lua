--[[
	Registers the creation of an object which can be used as a dependency.

	This is used to make sure objects don't capture dependencies originating
	from inside of themselves.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local sharedState = require(Package.Dependencies.sharedState)

local initialisedStack = sharedState.initialisedStack

local function initDependency(dependency: Types.Dependency<any>)
	local initialisedStackSize = sharedState.initialisedStackSize

	for index, initialisedSet in ipairs(initialisedStack) do
		if index > initialisedStackSize then
			return
		end

		initialisedSet[dependency] = true
	end
end

return initDependency