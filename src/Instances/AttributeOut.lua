--!strict

--[[
	A special key for property tables, which allows users to save instance attributes
    into state objects
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logError = require(Package.Logging.logError)
local logWarn = require(Package.Logging.logWarn)
local xtypeof = require(Package.Utility.xtypeof)
local assertLifetime = require(Package.Memory.assertLifetime)

local function AttributeOut(attributeName: string): PubTypes.SpecialKey
	local attributeOutKey = {}
	attributeOutKey.type = "SpecialKey"
	attributeOutKey.kind = "AttributeOut"
	attributeOutKey.stage = "observer"

	function attributeOutKey:apply(
		scope: PubTypes.Scope<any>,
		stateObject: any,
		applyTo: Instance
	)
		if xtypeof(stateObject) ~= "State" or stateObject.kind ~= "Value" then
			logError("invalidAttributeOutType")
		end
		if attributeName == nil then
			logError("attributeNameNil")
		end
		local ok, event = pcall(applyTo.GetAttributeChangedSignal, applyTo, attributeName)
		if not ok then
			logError("invalidOutAttributeName", applyTo.ClassName, attributeName)
		else
			if not assertLifetime(scope, nil, stateObject) then
				logWarn("possiblyOutlives", "Value object", `[AttributeOut "{attributeName}"]`)
			end
			stateObject:set((applyTo :: any):GetAttribute(attributeName))
			table.insert(scope, event:Connect(function()	
				stateObject:set((applyTo :: any):GetAttribute(attributeName))
			end))
		end
	end

	return attributeOutKey
end

return AttributeOut
