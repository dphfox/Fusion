--!strict
--!nolint LocalShadow

--[[
	A special key for property tables, which allows users to extract values from
	an instance into an automatically-updated Value object.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logError = require(Package.Logging.logError)
local logWarn = require(Package.Logging.logWarn)
local isState = require(Package.State.isState)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

local function Out(
	propertyName: string
): Types.SpecialKey
	return {
		type = "SpecialKey",
		kind = "Out",
		stage = "observer",
		apply = function(
			self: Types.SpecialKey,
			scope: Types.Scope<unknown>,
			value: unknown,
			applyTo: Instance
		)
			local ok, event = pcall(applyTo.GetPropertyChangedSignal, applyTo, propertyName)
			if not ok then
				logError("invalidOutProperty", nil, applyTo.ClassName, propertyName)
			end

			if not isState(value) then
				logError("invalidOutType")
			end
			local value = value :: Types.StateObject<unknown>
			if value.kind ~= "Value" then
				logError("invalidOutType")
			end
			local value = value :: Types.Value<unknown>

			if value.scope == nil then
				logError("useAfterDestroy", nil, `The Value, which [Out "{propertyName}"] outputs to,`, `the {applyTo.ClassName} instance`)
			elseif whichLivesLonger(scope, applyTo, value.scope, value) == "definitely-a" then
				logWarn("possiblyOutlives", `The Value, which [Out "{propertyName}"] outputs to,`, `the {applyTo.ClassName} instance`)
			end
			value:set((applyTo :: any)[propertyName])
			table.insert(
				scope,
				event:Connect(function()
					value:set((applyTo :: any)[propertyName])
				end)
			)
		end
	}
end

return Out
