--!strict

--[[
	Calls the given callback, and stores any used external dependencies.
	Arguments can be passed in after the callback.
	If the callback completed successfully, returns true and the returned value,
	otherwise returns false and the error thrown.
	The callback shouldn't yield or run asynchronously.

	NOTE: any calls to useDependency() inside the callback (even if inside any
	nested captureDependencies() call) will not be included in the set, to avoid
	self-dependencies.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local parseError = require(Package.Logging.parseError)
local sharedState = require(Package.Dependencies.sharedState)

type Set<T> = {[T]: any}

local initialisedStack = sharedState.initialisedStack
local initialisedStackCapacity = 0

local function captureDependencies(
	saveToSet: Set<PubTypes.Dependency>,
	callback: (...any) -> any,
	...
): (boolean, any)

	local prevDependencySet = sharedState.dependencySet
	sharedState.dependencySet = saveToSet

	sharedState.initialisedStackSize += 1
	local initialisedStackSize = sharedState.initialisedStackSize

	local initialisedSet
	if initialisedStackSize > initialisedStackCapacity then
		initialisedSet = {}
		initialisedStack[initialisedStackSize] = initialisedSet
		initialisedStackCapacity = initialisedStackSize
	else
		initialisedSet = initialisedStack[initialisedStackSize]
		table.clear(initialisedSet)
	end

	local data = table.pack(xpcall(callback, parseError, ...))

	sharedState.dependencySet = prevDependencySet
	sharedState.initialisedStackSize -= 1

	return table.unpack(data, 1, data.n)
end

return captureDependencies
