--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	A special key for property tables, which allows users to apply custom
	attributes to instances
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
local isState = require(Package.State.isState)
local Observer = require(Package.State.Observer)
local peek = require(Package.State.peek)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

local keyCache: {[string]: Types.SpecialKey} = {}

local function Attribute(
	attributeName: string
): Types.SpecialKey
	local key = keyCache[attributeName]
	if key == nil then
		key = {
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
						External.logError("useAfterDestroy", nil, `The {value.kind} object, bound to [Attribute "{attributeName}"],`, `the {applyTo.ClassName} instance`)
					elseif whichLivesLonger(scope, applyTo, value.scope, value.oldestTask) == "definitely-a" then
						External.logWarn("possiblyOutlives", `The {value.kind} object, bound to [Attribute "{attributeName}"],`, `the {applyTo.ClassName} instance`)
					end
					Observer(scope, value :: any):onBind(function()
						applyTo:SetAttribute(attributeName, peek(value))
					end)
				else
					applyTo:SetAttribute(attributeName, value)
				end
			end
		}
		keyCache[attributeName] = key
	end
	return key
end

return Attribute