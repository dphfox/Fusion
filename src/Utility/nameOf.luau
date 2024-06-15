--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Returns the most specific custom name for the given object.
]]

local Package = script.Parent.Parent
-- Utility
local nicknames = require(Package.Utility.nicknames)

local function nameOf(
	x: unknown,
	defaultName: string
): string
	local nickname = nicknames[x]
	if typeof(nickname) == "string" then
		return nickname
	end
	if typeof(x) == "table" then
		local x = x :: {[any]: any}
		if typeof(x.name) == "string" then
			return x.name
		elseif typeof(x.kind) == "string" then
			return x.kind
		elseif typeof(x.type) == "string" then
			return x.type
		end
	end
	return defaultName
end

return nameOf