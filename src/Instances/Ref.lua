--!strict

--[[
	A special key for property tables, which stores a reference to the instance
	in a user-provided Value object.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logWarn = require(Package.Logging.logWarn)
local logError = require(Package.Logging.logError)
local xtypeof = require(Package.Utility.xtypeof)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)

local Ref = {}
Ref.type = "SpecialKey"
Ref.kind = "Ref"
Ref.stage = "observer"

function Ref:apply(
	scope: PubTypes.Scope<any>,
	refState: any,
	applyTo: Instance
)
	if xtypeof(refState) ~= "State" or refState.kind ~= "Value" then
		logError("invalidRefType")
	else
		if whichLivesLonger(scope, applyTo, refState.scope, refState) == "a" then
			logWarn("possiblyOutlives", "The Value object, which [Ref] outputs to,", `the {applyTo} instance`)
		end
		refState:set(applyTo)
	end
end

return Ref