--!strict

--[[
	Creates cleanup tables with access to constructors as methods.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)

-- This return type is technically a lie, but it's required for useful type
-- checking behaviour.
local function scoped<T>(constructors: T): PubTypes.Scope<T>
	return setmetatable({}, {__index = constructors}) :: any
end

return scoped