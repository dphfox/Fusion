--!strict

--[[
	A special key for property tables, which allows users to apply custom
	attributes to instances
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local External = require(Package.External)
local logError = require(Package.Logging.logError)
local logWarn = require(Package.Logging.logWarn)
local isState = require(Package.State.isState)
local Observer = require(Package.State.Observer)
local peek = require(Package.State.peek)
local assertLifetime = require(Package.Memory.assertLifetime)

local function Attribute(attributeName: string): PubTypes.SpecialKey
	local AttributeKey = {}
	AttributeKey.type = "SpecialKey"
	AttributeKey.kind = "Attribute"
	AttributeKey.stage = "self"

	if attributeName == nil then
		logError("attributeNameNil")
	end

	function AttributeKey:apply(
		scope: PubTypes.Scope<any>,
		value: any,
		applyTo: Instance
	)
		if isState(value) then
			if not assertLifetime(scope, applyTo, value) then
				logWarn("possiblyOutlives", value.kind, `[Attribute "{attributeName}"]`)
			end
			local didDefer = false
			local function update()
				if not didDefer then
					didDefer = true
					External.doTaskDeferred(function()
						didDefer = false
						applyTo:SetAttribute(attributeName, peek(value))
					end)
				end
			end
			applyTo:SetAttribute(attributeName, peek(value))
			table.insert(scope, Observer(scope, value :: any):onChange(update))
		else
			applyTo:SetAttribute(attributeName, value)
		end
	end
	return AttributeKey
end

return Attribute