--!strict

--[[
	Generates symbols used to denote event handlers when working with the `New`
	function.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)

local function OnEvent(eventName: string): Types.OnEventKey
	return {
		type = "Symbol",
		name = "OnEvent",
		key = eventName
	}
end

return OnEvent