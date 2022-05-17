--!strict

--[[
	A special key for property tables, which allows users to extract values from
	an instance into an automatically-updated Value object.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.Instances.PubTypes)
local logError = require(Package.Core.Logging.logError)
local xtypeof = require(Package.Core.Utility.xtypeof)

local function Out(propertyName: string): PubTypes.SpecialKey
	local outKey = {}
	outKey.type = "SpecialKey"
	outKey.kind = "Out"
	outKey.stage = "observer"

	function outKey:apply(outState: any, applyToRef: PubTypes.SemiWeakRef, cleanupTasks: { PubTypes.Task })
		local ok, event = pcall(applyToRef.instance.GetPropertyChangedSignal, applyToRef.instance, propertyName)
		if not ok then
			logError("invalidOutProperty", nil, applyToRef.instance.ClassName, propertyName)
		elseif xtypeof(outState) ~= "State" or outState.kind ~= "Value" then
			logError("invalidOutType")
		else
			outState:set((applyToRef.instance :: any)[propertyName])
			table.insert(
				cleanupTasks,
				event:Connect(function()
					if applyToRef.instance ~= nil then
						outState:set((applyToRef.instance :: any)[propertyName])
					end
				end)
			)
			table.insert(cleanupTasks, function()
				outState:set(nil)
			end)
		end
	end

	return outKey
end

return Out