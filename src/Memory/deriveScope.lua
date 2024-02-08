--!strict
--!nolint LocalShadow

--[[
	Creates an empty scope with the same metatables as the original scope. Used
	for preserving access to constructors when creating inner scopes.
]]
local Package = script.Parent.Parent
local Types = require(Package.Types)
local scopePool = require(Package.Memory.scopePool)

-- This return type is technically a lie, but it's required for useful type
-- checking behaviour.
local function deriveScope<T>(
	existing: Types.Scope<T>
): Types.Scope<T>
	return setmetatable(
		scopePool.reuseAny() or {},
		getmetatable(existing)
	) :: any
end

return deriveScope