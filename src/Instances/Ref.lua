--!strict

--[[
	A special key for property tables, which stores a reference to the instance
	in a user-provided Value object.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logWarn = require(Package.Logging.logWarn)
local logError = require(Package.Logging.logError)
local isState = require(Package.State.isState)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

return {
	type = "SpecialKey",
	kind = "Ref",
	stage = "observer",
	apply = function(
		self: PubTypes.SpecialKey,
		scope: PubTypes.Scope<any>,
		refState: any,
		applyTo: Instance
	)
		if not isState(refState) or refState.kind ~= "Value" then
			logError("invalidRefType")
		else
			if refState.scope == nil then
				logError("useAfterDestroy", nil, "The Value object, which [Ref] outputs to,", `the {applyTo} instance`)
			elseif whichLivesLonger(scope, applyTo, refState.scope, refState) == "a" then
				logWarn("possiblyOutlives", "The Value object, which [Ref] outputs to,", `the {applyTo} instance`)
			end
			refState:set(applyTo)
		end
	end
} :: PubTypes.SpecialKey