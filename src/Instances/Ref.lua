--!strict
--!nolint LocalShadow

--[[
	A special key for property tables, which stores a reference to the instance
	in a user-provided Value object.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logWarn = require(Package.Logging.logWarn)
local logError = require(Package.Logging.logError)
local isState = require(Package.State.isState)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

return {
	type = "SpecialKey",
	kind = "Ref",
	stage = "observer",
	apply = function(
		self: Types.SpecialKey,
		scope: Types.Scope<unknown>,
		value: unknown,
		applyTo: Instance
	)
		if not isState(value) then
			logError("invalidRefType")
		end
		local value = value :: Types.StateObject<unknown>
		if value.kind ~= "Value" then
			logError("invalidRefType")
		end
		local value = value :: Types.Value<unknown>

		if value.scope == nil then
			logError("useAfterDestroy", nil, "The Value object, which [Ref] outputs to,", `the {applyTo} instance`)
		elseif whichLivesLonger(scope, applyTo, value.scope, value) == "definitely-a" then
			logWarn("possiblyOutlives", "The Value object, which [Ref] outputs to,", `the {applyTo} instance`)
		end
		value:set(applyTo)
	end
} :: Types.SpecialKey