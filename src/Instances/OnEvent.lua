--!strict

--[[
	Generates symbols used to denote event handlers when working with the `New`
	function.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)

local function OnEvent(eventName: string): PubTypes.OnEventKey
	return {
		type = "Symbol",
		name = "OnEvent",
		key = eventName
	}
end

return OnEvent