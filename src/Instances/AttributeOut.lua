--!strict
--!nolint LocalShadow

--[[
	A special key for property tables, which allows users to save instance attributes
	into state objects
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logError = require(Package.Logging.logError)
local logWarn = require(Package.Logging.logWarn)
local isState = require(Package.State.isState)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

local function AttributeOut(
	attributeName: string
): Types.SpecialKey
	return {
		type = "SpecialKey",
		kind = "AttributeOut",
		stage = "observer",
		apply = function(
			self: Types.SpecialKey,
			scope: Types.Scope<unknown>,
			value: unknown,
			applyTo: Instance
		)
			local event = applyTo:GetAttributeChangedSignal(attributeName)

			if not isState(value) then
				logError("invalidAttributeOutType")
			end
			local value = value :: Types.StateObject<unknown>
			if value.kind ~= "Value" then
				logError("invalidAttributeOutType")
			end
			local value = value :: Types.Value<unknown>
			
			if value.scope == nil then
				logError("useAfterDestroy", nil, `The Value object, which [AttributeOut "{attributeName}"] outputs to,`, `the {applyTo.ClassName} instance`)
			elseif whichLivesLonger(scope, applyTo, value.scope, value) == "definitely-a" then
				logWarn("possiblyOutlives", `The Value object, which [AttributeOut "{attributeName}"] outputs to,`, `the {applyTo.ClassName} instance`)
			end
			value:set((applyTo :: any):GetAttribute(attributeName))
			table.insert(scope, event:Connect(function()	
				value:set((applyTo :: any):GetAttribute(attributeName))
			end))
		end
	}
end

return AttributeOut
