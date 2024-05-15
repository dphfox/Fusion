--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	A special key for property tables, which allows users to extract values from
	an instance into an automatically-updated Value object.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
local isState = require(Package.State.isState)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

local keyCache: {[string]: Types.SpecialKey} = {}

local function Out(
	propertyName: string
): Types.SpecialKey
	local key = keyCache[propertyName]
	if key == nil then
		key = {
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
					External.logError("invalidOutProperty", nil, applyTo.ClassName, propertyName)
				end
	
				if not isState(value) then
					External.logError("invalidOutType")
				end
				local value = value :: Types.StateObject<unknown>
				if value.kind ~= "Value" then
					External.logError("invalidOutType")
				end
				local value = value :: Types.Value<unknown>
	
				if value.scope == nil then
					External.logError("useAfterDestroy", nil, `The Value, which [Out "{propertyName}"] outputs to,`, `the {applyTo.ClassName} instance`)
				elseif whichLivesLonger(scope, applyTo, value.scope, value.oldestTask) == "definitely-a" then
					External.logWarn("possiblyOutlives", `The Value, which [Out "{propertyName}"] outputs to,`, `the {applyTo.ClassName} instance`)
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
		keyCache[propertyName] = key
	end
	return key
end

return Out
