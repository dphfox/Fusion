--!strict
--!nolint LocalShadow

--[[
	Creates cleanup tables with access to constructors as methods.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logError = require(Package.Logging.logError)
local scopePool = require(Package.Memory.scopePool)

local function merge(
	into: {[unknown]: unknown},
	from: {[unknown]: unknown}?,
	...: {[unknown]: unknown}
): {[unknown]: unknown}
	if from == nil then
		return into
	else
		for key, value in from do
			if into[key] == nil then
				into[key] = value
			else
				logError("mergeConflict", nil, tostring(key))
			end
		end
		return merge(into, ...)
	end
end

local function scoped(
	...: {[unknown]: unknown}
): {[unknown]: unknown}
	return setmetatable(
		scopePool.reuseAny() or {},
		{__index = merge({}, ...)}
	) :: any
end

return (scoped :: any) :: Types.ScopedConstructor