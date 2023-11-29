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
local assertLifetime = require(Package.Memory.assertLifetime)

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
		if not assertLifetime(scope, refState, applyTo) then
			logWarn("possiblyOutlives", "Value", "[Ref]")
		end
		refState:set(applyTo)
	end
end

return Ref