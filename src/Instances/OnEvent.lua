--!strict

--[[
	Constructs special keys for property tables which connect event listeners to
	an instance.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logError = require(Package.Logging.logError)
local xtypeof = require(Package.Utility.xtypeof)

local function getProperty_unsafe(instance: Instance, property: string)
	return (instance :: any)[property]
end

local function OnEvent(eventName: string): PubTypes.SpecialKey
	local eventKey = {}
	eventKey.type = "SpecialKey"
	eventKey.kind = "OnEvent"
	eventKey.stage = "observer"

	function eventKey:apply(callback: any, applyTo: Instance, cleanupTasks: {PubTypes.Task})
		local ok, event = pcall(getProperty_unsafe, applyTo, eventName)
		if not ok or typeof(event) ~= "RBXScriptSignal" then
			logError("cannotConnectEvent", nil, applyTo.ClassName, eventName)
			return
		end

		if typeof(callback) ~= "function" and xtypeof(callback) ~= "state" then
			logError("invalidEventHandler", nil, eventName)
		else
			table.insert(cleanupTasks, event:Connect(function()
				if xtypeof(callback) == "state" then
					callback = peek(callback)
				end
				callback()
			end))
		end
	end

	return eventKey
end

return OnEvent