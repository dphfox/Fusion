--[[
	Generates symbols used to denote event handlers when working with the `New`
	function.
]]

local function OnEvent(eventName: string)
	return {
		type = "Symbol",
		name = "OnEvent",
		key = eventName
	}
end

return OnEvent