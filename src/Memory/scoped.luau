--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Creates cleanup tables with access to constructors as methods.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local merge = require(Package.Utility.merge)
local scopePool = require(Package.Memory.scopePool)

local function scoped(
	...: {[unknown]: unknown}
): {[unknown]: unknown}
	return setmetatable(
		scopePool.reuseAny() :: any or {},
		{__index = merge(false, {}, ...)}
	) :: any
end

return (scoped :: any) :: Types.ScopedConstructor