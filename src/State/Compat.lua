--[[
	Constructs a new state object, which exposes compatibility APIs for
	integrating with non-reactive code.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local initDependency = require(Package.Dependencies.initDependency)

local class = {}
local CLASS_METATABLE = {__index = class}

-- Table used to hold Compat objects in memory.
local strongRefs = {}

--[[
	Called when the watched state changes value.
]]
function class:update()
	for callback in pairs(self._changeListeners) do
		coroutine.wrap(callback)()
	end
	return false
end

--[[
	Adds a change listener. When the watched state changes value, the listener
	will be fired.

	Returns a function which, when called, will disconnect the change listener.
	As long as there is at least one active change listener, this Compat object
	will be held in memory, preventing GC, so disconnecting is important.
]]
function class:onChange(callback: () -> ())
	self._numChangeListeners += 1
	self._changeListeners[callback] = true

	-- disallow gc (this is important to make sure changes are received)
	strongRefs[self] = true

	local disconnected = false
	return function()
		if disconnected then
			return
		end
		disconnected = true
		self._changeListeners[callback] = nil
		self._numChangeListeners -= 1

		if self._numChangeListeners == 0 then
			-- allow gc if all listeners are disconnected
			strongRefs[self] = nil
		end
	end
end

local function Compat(watchedState: Types.State<any>)
	local self = setmetatable({
		type = "State",
		kind = "Compat",
		dependencySet = {[watchedState] = true},
		dependentSet = {},
		_changeListeners = {},
		_numChangeListeners = 0
	}, CLASS_METATABLE)

	initDependency(self)
	-- add this object to the watched state's dependent set
	watchedState.dependentSet[self] = true

	return self
end

return Compat