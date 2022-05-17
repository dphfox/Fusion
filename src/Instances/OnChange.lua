--!strict

--[[
	Constructs special keys for property tables which connect property change
	listeners to an instance.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.Instances.PubTypes)
local logError = require(Package.Core.Logging.logError)

local function OnChange(propertyName: string): PubTypes.SpecialKey
	local changeKey = {}
	changeKey.type = "SpecialKey"
	changeKey.kind = "OnChange"
	changeKey.stage = "observer"

	function changeKey:apply(callback: any, applyToRef: PubTypes.SemiWeakRef, cleanupTasks: {PubTypes.Task})
		local instance = applyToRef.instance :: Instance
		local ok, event = pcall(instance.GetPropertyChangedSignal, instance, propertyName)
		if not ok then
			logError("cannotConnectChange", nil, instance.ClassName, propertyName)
		elseif typeof(callback) ~= "function" then
			logError("invalidChangeHandler", nil, propertyName)
		else
			table.insert(cleanupTasks, event:Connect(function()
				if applyToRef.instance ~= nil then
					callback((applyToRef.instance :: any)[propertyName])
				end
			end))
		end
	end

	return changeKey
end

return OnChange