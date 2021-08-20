--[[
	An xpcall() error handler to collect and parse useful information about
	errors, such as clean messages and stack traces.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)

local function parseError(err: string): Types.Error
	return {
		raw = err,
		message = err:gsub("^.+:%d+:%s*", ""),
		trace = debug.traceback(nil, 2)
	}
end

return parseError