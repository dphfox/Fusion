--[[
	Calls the given callback, and stores any used external dependencies.
	Arguments can be passed in after the callback.
	If the callback completed successfully, returns true and the returned value,
	otherwise returns false and the error thrown.
	The callback shouldn't yield or run asynchronously.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local parseError = require(Package.Logging.parseError)
local sharedState = require(Package.Dependencies.sharedState)

local initialisedStack = sharedState.initialisedStack
-- counts how many sets are currently stored in `initialisedStack`, whether
-- they're currently in use or not
local initialisedStackCapacity = 0

local function captureDependencies(saveToSet: Types.Set<Types.Dependency<any>>, callback: (any) -> any, ...): (boolean, any)
	-- store whichever set was being saved to previously, and replace it with
	-- the new set which was passed in
	local prevDependencySet = sharedState.dependencySet
	sharedState.dependencySet = saveToSet

	-- Add a new 'initialised' set to the stack of initialised sets.
	-- If a dependency is created inside the callback (even if indirectly inside
	-- a different `captureDependencies` call), it'll be added to this set.
	-- This can be used to ignore dependencies that were created inside of the
	-- callback.
	sharedState.initialisedStackSize += 1
	local initialisedStackSize = sharedState.initialisedStackSize

	local initialisedSet

	-- instead of constructing new sets all of the time, we can simply leave old
	-- sets in the stack and keep track of the 'real' number of sets ourselves.
	-- this means we don't have to keep creating and throwing away tables, which
	-- is great for performance at the expense of slightly more memory usage.
	if initialisedStackSize > initialisedStackCapacity then
		-- the stack has grown beyond any previous size, so we need to create
		-- a new table
		initialisedSet = {}
		initialisedStack[initialisedStackSize] = initialisedSet
		initialisedStackCapacity = initialisedStackSize
	else
		-- the stack is smaller or equal to some previous size, so we just need
		-- to clear whatever set was here before
		initialisedSet = initialisedStack[initialisedStackSize]
		table.clear(initialisedSet)
	end

	-- now that the shared state has been set up, call the callback in a pcall.
	-- using a pcall means the shared state can be reset afterwards, even if an
	-- error occurs.
	local ok, value = xpcall(callback, parseError, ...)

	-- restore the previous set being saved to
	sharedState.dependencySet = prevDependencySet
	-- shrink the stack of initialised sets (essentially removing this set)
	sharedState.initialisedStackSize -= 1

	return ok, value
end

return captureDependencies