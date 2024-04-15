--!strict
--!nolint LocalShadow

--[[
	An xpcall() error handler to collect and parse useful information about
	errors, such as clean messages and stack traces.
]]

local Package = script.Parent.Parent
local InternalTypes = require(Package.InternalTypes)

local function parseError(
	err: string
): InternalTypes.Error
	return {
		type = "Error",
		raw = err,
		message = err:gsub("^.+:%d+:%s*", ""),
		trace = debug.traceback(nil, 2)
	}
end

return parseError