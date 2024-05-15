--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Constructs a new state object which can listen for updates on another state
	object.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local InternalTypes = require(Package.InternalTypes)
local External = require(Package.External)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

local class = {}
class.type = "Observer"

local CLASS_METATABLE = {__index = class}

--[[
	Called when the watched state changes value.
]]
function class:update(): boolean
	local self = self :: InternalTypes.Observer
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
function class:onChange(
	callback: () -> ()
): () -> ()
	local self = self :: InternalTypes.Observer
	local uniqueIdentifier = {}
	self._changeListeners[uniqueIdentifier] = callback
	return function()
		self._changeListeners[uniqueIdentifier] = nil
	end
end

--[[
	Similar to `class:onChange()`, however it runs the provided callback
	immediately.
]]
function class:onBind(
	callback: () -> ()
): () -> ()
	local self = self :: InternalTypes.Observer
	External.doTaskImmediate(callback)
	return self:onChange(callback)
end

local function Observer(
	scope: Types.Scope<unknown>,
	watching: unknown
): Types.Observer
	if watching == nil then
		External.logError("scopeMissing", nil, "Observers", "myScope:Observer(watching)")
	end

	local watchingState = typeof(watching) == "table" and (watching :: any).dependentSet ~= nil

	local self = setmetatable({
		scope = scope,
		dependencySet = if watchingState then {[watching] = true} else {},
		dependentSet = {},
		_changeListeners = {}
	}, CLASS_METATABLE)
	local self = (self :: any) :: InternalTypes.Observer
	
	local destroy = function()
		self.scope = nil
		for dependency in pairs(self.dependencySet) do
			dependency.dependentSet[self] = nil
		end
	end
	self.oldestTask = destroy
	table.insert(scope, destroy)

	if watchingState then
		local watching: any = watching
		if watching.scope == nil then
			External.logError(
				"useAfterDestroy",
				nil,
				`The {watching.kind or watching.type or "watched"} object`,
				`the Observer that is watching it`
			)
		elseif whichLivesLonger(scope, self.oldestTask, watching.scope, watching.oldestTask) == "definitely-a" then
			local watching: any = watching
			External.logWarn(
				"possiblyOutlives",
				`The {watching.kind or watching.type or "watched"} object`,
				`the Observer that is watching it`
			)
		end
		-- add this object to the watched object's dependent set
		watching.dependentSet[self] = true
	end

	return self
end

return Observer