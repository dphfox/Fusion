--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Creates an empty scope with the same metatables as the original scope. Used
	for preserving access to constructors when creating inner scopes.

	This is the internal version of the function, which does not implement
	external debugging hooks.
]]
local Package = script.Parent.Parent
local Types = require(Package.Types)
local merge = require(Package.Utility.merge)
local scopePool = require(Package.Memory.scopePool)

-- This return type is technically a lie, but it's required for useful type
-- checking behaviour.
local function deriveScopeImpl<T>(
	existing: Types.Scope<T>,
	methods: {[unknown]: unknown}?,
	...: {[unknown]: unknown}
): any
	local metatable = getmetatable(existing)
	if methods ~= nil then
		metatable = table.clone(metatable)
		metatable.__index = merge(
			true, {}, 
			metatable.__index, 
			merge(
				false, {},
				methods, 
				...
			)
		)
	end
	local scope = setmetatable(
		scopePool.reuseAny() :: any or {},
		metatable
	)
	return scope
end

return (deriveScopeImpl :: any) :: Types.DeriveScopeConstructor