--!strict
--!nolint LocalShadow

--[[
	Creates an empty scope with the same metatables as the original scope. Used
	for preserving access to constructors when creating inner scopes.
]]
local Package = script.Parent.Parent
local Types = require(Package.Types)

-- This return type is technically a lie, but it's required for useful type
-- checking behaviour.
local function deriveScope<S>(scope: Types.Scope<S>): Types.Scope<S>
	return setmetatable({}, getmetatable(scope)) :: any
end

return deriveScope