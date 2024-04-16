--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Attempts to revalidate a graph object.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)

local function tryRevalidate(
	target: Types.GraphObject
): ()
	if not target.valid then
		local meaningfulChange = target:duringRevalidation()
		if meaningfulChange or target.lastChange == nil then
			target.lastChange = os.clock()
		end
		target.valid = true
	end
end

return tryRevalidate