--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Utility function to log a Fusion-specific warning.
]]

local Package = script.Parent.Parent
local formatError = require(Package.Logging.formatError)

local function logWarn(
	messageID: string,
	...: unknown
): ()
	warn(
		formatError(
			messageID, 
			debug.traceback(nil, 3),
			...
		)
	)
end

return logWarn