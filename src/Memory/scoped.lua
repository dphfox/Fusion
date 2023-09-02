--!strict

--[[
	Creates cleanup tables with access to constructors as methods.
]]

-- This return type is technically a lie, but it's required for useful type
-- checking behaviour.
local function scoped<T>(constructors: T): T
	return setmetatable({}, {__index = constructors}) :: any
end

return scoped