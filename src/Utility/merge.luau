--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Attempts to merge a variadic number of tables together.
]]

local Package = script.Parent.Parent
local External = require(Package.External)

local function merge(
	overwrite: "none" | "first" | "all",
	into: {[unknown]: unknown},
	from: {[unknown]: unknown}?,
	...: {[unknown]: unknown}
): {[unknown]: unknown}
	if from == nil then
		return into
	else
		for key, value in from do
			if into[key] ~= nil and overwrite == "none" then
				External.logError("mergeConflict", nil, tostring(key))
			else
				into[key] = value
			end
		end
		return merge(if overwrite == "first" then "none" else overwrite, into, ...)
	end
end

return merge
