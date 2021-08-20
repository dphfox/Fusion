--[[
	Restricts the reading of missing members for a table.
]]

local Package = script.Parent.Parent
local logError = require(Package.Logging.logError)

local function restrictRead(tableName: string, strictTable: table): table
	local metatable = getmetatable(strictTable)

	if metatable == nil then
		metatable = {}
		setmetatable(strictTable, metatable)
	end

	function metatable:__index(memberName)
		logError("strictReadError", nil, tostring(memberName), tableName)
	end

	return strictTable
end

return restrictRead