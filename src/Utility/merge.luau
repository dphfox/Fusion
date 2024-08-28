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
	overwrite: boolean,
	into: {[unknown]: unknown},
	...: {[unknown]: unknown}
): {[unknown]: unknown}
	local fromTables = {...}
	if #fromTables < 1 then
		return into
	else
		for _, fromTable in fromTables do
			for key, value in fromTable do
				if into[key] == nil then
					into[key] = value
				elseif not overwrite then
					External.logError("mergeConflict", nil, tostring(key))
				end
			end
		end
		return into
	end
end

return merge
