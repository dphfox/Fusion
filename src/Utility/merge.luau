--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Attempts to merge a variadic number of tables together.
]]

local Package = script.Parent.Parent
local logError = require(Package.Logging.logError)

local function merge(
	overwrite: boolean,
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
			elseif not overwrite then
				logError("mergeConflict", nil, tostring(key))
			end
		end
		return merge(overwrite, into, ...)
	end
end

return merge
