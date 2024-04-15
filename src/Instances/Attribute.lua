--!strict
--!nolint LocalShadow

--[[
	A special key for property tables, which allows users to apply custom
	attributes to instances
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
local logError = require(Package.Logging.logError)
local logWarn = require(Package.Logging.logWarn)
local isState = require(Package.State.isState)
local Observer = require(Package.State.Observer)
local peek = require(Package.State.peek)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

local function Attribute(
	attributeName: string
): Types.SpecialKey
	return {
		type = "SpecialKey",
		kind = "Attribute",
		stage = "self",
		apply = function(
			self: Types.SpecialKey,
			scope: Types.Scope<unknown>,
			value: unknown,
			applyTo: Instance
		)
			if isState(value) then
				local value = value :: Types.StateObject<unknown>
				if value.scope == nil then
					logError("useAfterDestroy", nil, `The {value.kind} object, bound to [Attribute "{attributeName}"],`, `the {applyTo.ClassName} instance`)
				elseif whichLivesLonger(scope, applyTo, value.scope, value) == "definitely-a" then
					logWarn("possiblyOutlives", `The {value.kind} object, bound to [Attribute "{attributeName}"],`, `the {applyTo.ClassName} instance`)
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
	}
end

return Attribute