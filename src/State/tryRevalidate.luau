--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Attempts to revalidate a graph object.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logError = require(Package.Logging.logError)

local function tryRevalidate(
	target: Types.GraphObject
): ()
	if target.validity == "invalid" then
		target.validity = "busy"
		local meaningfulChange = target:duringRevalidation()
		target.validity = "valid"
		if meaningfulChange or target.lastChange == nil then
			target.lastChange = os.clock()
		end
	elseif target.validity == "busy" then
		return logError("infiniteLoop")
	end
end

return tryRevalidate