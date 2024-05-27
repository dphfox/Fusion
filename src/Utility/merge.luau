--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Attempts to merge a variadic number of tables together.
]]

local Package = script.Parent.Parent
<<<<<<< HEAD
local logError = require(Package.Logging.logError)
=======
local External = require(Package.External)
>>>>>>> upstream/main

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
			if into[key] == nil then
				into[key] = value
			elseif overwrite == "none" then
<<<<<<< HEAD
				logError("mergeConflict", nil, tostring(key))
=======
				External.logError("mergeConflict", nil, tostring(key))
>>>>>>> upstream/main
			end
		end
		return merge(if overwrite == "first" then "none" else overwrite, into, ...)
	end
end

return merge
