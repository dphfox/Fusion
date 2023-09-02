--!strict

--[[
	Creates cleanup tables with access to constructors as methods.
]]

local function scoped(...)
	local merged = {}
	for name, func in {...} do
		merged[name] = func
	end
	return setmetatable({}, {__index = merged}) :: any
end

return scoped