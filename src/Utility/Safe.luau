--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
    A variant of xpcall() designed for inline usage, letting you define fallback
	values based on caught errors.
]]

local Package = script.Parent.Parent

local function Safe<Success, Fail>(
	callbacks: {
		try: () -> Success,
		fallback: (err: unknown) -> Fail
	}
): Success | Fail
	local _, value = xpcall(callbacks.try, callbacks.fallback)
	return value
end

return Safe