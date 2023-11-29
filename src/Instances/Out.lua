--!strict

--[[
	A special key for property tables, which allows users to extract values from
	an instance into an automatically-updated Value object.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logError = require(Package.Logging.logError)
local logWarn = require(Package.Logging.logWarn)
local xtypeof = require(Package.Utility.xtypeof)
local assertLifetime = require(Package.Memory.assertLifetime)

local function Out(propertyName: string): PubTypes.SpecialKey
	local outKey = {}
	outKey.type = "SpecialKey"
	outKey.kind = "Out"
	outKey.stage = "observer"

	function outKey:apply(
		scope: PubTypes.Scope<any>,
		outState: any,
		applyTo: Instance
	)
		local ok, event = pcall(applyTo.GetPropertyChangedSignal, applyTo, propertyName)
		if not ok then
			logError("invalidOutProperty", nil, applyTo.ClassName, propertyName)
		elseif xtypeof(outState) ~= "State" or outState.kind ~= "Value" then
			logError("invalidOutType")
		else
			if not assertLifetime(scope, nil, outState) then
				logWarn("possiblyOutlives", "Value object", `[Out "{propertyName}"]`)
			end
			outState:set((applyTo :: any)[propertyName])
			table.insert(
				scope,
				event:Connect(function()
					outState:set((applyTo :: any)[propertyName])
				end)
			)
		end
	end

	return outKey
end

return Out
