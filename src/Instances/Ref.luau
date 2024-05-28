--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	A special key for property tables, which stores a reference to the instance
	in a user-provided Value object.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
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
			External.logError("invalidRefType")
		end
		local value = value :: Types.StateObject<unknown>
		if value.kind ~= "Value" then
			External.logError("invalidRefType")
		end
		local value = value :: Types.Value<unknown>

		if value.scope == nil then
			External.logError("useAfterDestroy", nil, "The Value object, which [Ref] outputs to,", `the {applyTo} instance`)
		elseif whichLivesLonger(scope, applyTo, value.scope, value.oldestTask) == "definitely-a" then
			External.logWarn("possiblyOutlives", "The Value object, which [Ref] outputs to,", `the {applyTo} instance`)
		end
		value:set(applyTo)
	end
} :: Types.SpecialKey