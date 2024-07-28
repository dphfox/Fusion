--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Abstraction layer between Fusion internals and external debuggers, allowing
	for deep introspection using function hooks.

	Unlike `External`, attaching a debugger is optional, and all debugger
	functions are expected to be infallible and non-blocking.
]]

local Package = script.Parent
local Types = require(Package.Types)

local currentProvider: Types.ExternalDebugger? = nil
local lastUpdateStep = 0

local Debugger = {}

--[[
	Swaps to a new debugger.
	Returns the old debugger, so it can be used again later.
]]
function Debugger.setDebugger(
	newProvider: Types.ExternalDebugger?
): Types.ExternalDebugger?
	local oldProvider = currentProvider
	if oldProvider ~= nil then
		oldProvider.stopDebugging()
	end
	currentProvider = newProvider
	if newProvider ~= nil then
		newProvider.startDebugging()
	end
	return oldProvider
end

--[[
	Called at the earliest moment after a scope is created or removed from the
	scope pool, but not before the scope has finished being prepared by the
	library, so that debuggers can register its existence and track changes
	to the scope over time.
]]
function Debugger.trackScope(
	scope: Types.Scope<unknown>
): ()
	if currentProvider == nil then
		return
	end
	currentProvider.trackScope(scope)
end

--[[
	Called at the final moment before a scope is poisoned or added to the scope
	pool, after all cleanup tasks have completed, so that debuggers can erase 
	the scope from internal trackers. Note that, due to scope pooling and user
	code, never assume that this correlates with garbage collection events.
]]
function Debugger.untrackScope(
	scope: Types.Scope<unknown>
): ()
	if currentProvider == nil then
		return
	end
	currentProvider.trackScope(scope)
end

return Debugger