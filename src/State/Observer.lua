--!nonstrict

--[[
	Constructs a new state object which can listen for updates on another state
	object.

	FIXME: enabling strict types here causes free types to leak
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Types = require(Package.Types)
local External = require(Package.External)

local observerCache: { [PubTypes.Value<any>]: Types.Observer } = {}

local class = {}
local CLASS_METATABLE = { __index = class }

--[[
	Called when the watched state changes value.
]]
function class:update(): boolean
	for _, callback in pairs(self._changeListeners) do
		External.doTaskImmediate(callback)
	end
	return false
end

--[[
	Adds a change listener. When the watched state changes value, the listener
	will be fired.

	Returns a function which, when called, will disconnect the change listener.
	As long as there is at least one active change listener, this Observer
	will be held in memory, preventing GC, so disconnecting is important.
]]
function class:onChange(callback: () -> ()): () -> ()
	local uniqueIdentifier = {}

	self._numChangeListeners += 1
	self._changeListeners[uniqueIdentifier] = callback

	local disconnected = false
	return function()
		if disconnected then
			return
		end
		disconnected = true
		self._changeListeners[uniqueIdentifier] = nil
		self._numChangeListeners -= 1

		if self._numChangeListeners == 0 then
			-- allow gc if all listeners are disconnected
			-- by removing this observer from the hardRef cache
			for state in pairs(self.dependencySet) do
				observerCache[state] = nil
			end
		end
	end
end

--[[
	Similar to `class:onChange()`, however it runs the provided callback
	immediately.
]]
function class:onBind(callback: () -> ()): () -> ()
	External.doTaskImmediate(callback)
	return self:onChange(callback)
end

local function Observer(watchedState: PubTypes.Value<any>): Types.Observer
	if observerCache[watchedState] then
		return observerCache[watchedState]
	end

	local self = setmetatable({
		type = "State",
		kind = "Observer",
		dependencySet = { [watchedState] = true },
		dependentSet = {},
		_changeListeners = {},
		_numChangeListeners = 0,
	}, CLASS_METATABLE)

	-- add this object to the watched state's dependent set
	watchedState.dependentSet[self] = true

	observerCache[watchedState] = self

	return self
end

return Observer
