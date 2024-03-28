--!strict

--[[
	Constructs special keys for property tables which connect property change
	listeners to an instance.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logError = require(Package.Logging.logError)
local xtypeof = require(Package.Utility.xtypeof)
local peek = require(Package.State.peek)

local function OnChange(propertyName: string): PubTypes.SpecialKey
	local changeKey = {}
	changeKey.type = "SpecialKey"
	changeKey.kind = "OnChange"
	changeKey.stage = "observer"

	function changeKey:apply(callback: any, applyTo: Instance, cleanupTasks: {PubTypes.Task})
		local ok, event = pcall(applyTo.GetPropertyChangedSignal, applyTo, propertyName)
		if not ok then
			logError("cannotConnectChange", nil, applyTo.ClassName, propertyName)
			return
		end
		if typeof(callback) ~= "function" and xtypeof(callback) ~= "state" then
			logError("invalidChangeHandler", nil, propertyName)
		else
			table.insert(cleanupTasks, event:Connect(function()
				local newValue = (applyTo :: any)[propertyName]
				if xtypeof(callback) == "state" then
					callback = peek(callback)
				end
				callback(newValue)
			end))
		end
	end

	return changeKey
end

return OnChange