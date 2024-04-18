--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Derives a new scope that's destroyed exactly once, whether by the user or by
	the scope that it's inside of.
]]
local Package = script.Parent.Parent
local Types = require(Package.Types)
local deriveScope = require(Package.Memory.deriveScope)

local function innerScope<T>(
	existing: Types.Scope<T>
): Types.Scope<T>
	local new = deriveScope(existing)
	table.insert(existing, new)
	table.insert(
		new, 
		function()
			local index = table.find(existing, new)
			if index ~= nil then
				table.remove(existing, new)
			end
		end
	)
	return new
end

return innerScope