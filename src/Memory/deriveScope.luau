--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Creates an empty scope with the same metatables as the original scope. Used
	for preserving access to constructors when creating inner scopes.

	This is the public version of the function, which implements external
	debugging hooks.
]]
local Package = script.Parent.Parent
local Types = require(Package.Types)
local ExternalDebug = require(Package.ExternalDebug)
local deriveScopeImpl = require(Package.Memory.deriveScopeImpl)

local function deriveScope(...)
	local scope = deriveScopeImpl(...)
	ExternalDebug.trackScope(scope)
	return scope
end

return deriveScope :: Types.DeriveScopeConstructor