--[[
	The Context object implements a write-once key-value store. It also allows
	for a new Context object to inherit the entries from an existing one.
]]
local Context = {}

function Context.new(parent)
	local meta = {}
	local index = {}
	meta.__index = index

	if parent then
		for key, value in pairs(getmetatable(parent).__index) do
			index[key] = value
		end
	end

	function meta.__newindex(_obj, key, value)
		assert(index[key] == nil, string.format("Cannot reassign %s in context", tostring(key)))
		index[key] = value
	end

	return setmetatable({}, meta)
end

return Context
