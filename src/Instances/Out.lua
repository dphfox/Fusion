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
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

local function Out(propertyName: string): PubTypes.SpecialKey
	return {
		type = "SpecialKey",
		kind = "Out",
		stage = "observer",
		apply = function(
			self: PubTypes.SpecialKey,
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
				if outState.scope == nil then
					logError("useAfterDestroy", nil, `The Value, which [Out "{propertyName}"] outputs to,`, `the {applyTo.ClassName} instance`)
				elseif whichLivesLonger(scope, applyTo, outState.scope, outState) == "a" then
					logWarn("possiblyOutlives", `The Value, which [Out "{propertyName}"] outputs to,`, `the {applyTo.ClassName} instance`)
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
	}
end

return Out
