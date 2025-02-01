--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Creates cleanup tables with access to constructors as methods.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local ExternalDebug = require(Package.ExternalDebug)
local merge = require(Package.Utility.merge)

local function scoped(
	...: {[unknown]: unknown}
): any
	local metatable = {__index = merge(false, {}, ...)}
	local scope = setmetatable({}, metatable) :: any
	ExternalDebug.trackScope(scope)
	return scope
end

return (scoped :: any) :: Types.ScopedConstructor