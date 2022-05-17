--!strict

--[[
	A special key for property tables, which stores a reference to the instance
	in a user-provided Value object.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.Instances.PubTypes)
local logError = require(Package.Core.Logging.logError)
local xtypeof = require(Package.Core.Utility.xtypeof)

local Ref = {}
Ref.type = "SpecialKey"
Ref.kind = "Ref"
Ref.stage = "observer"

function Ref:apply(refState: any, applyToRef: PubTypes.SemiWeakRef, cleanupTasks: {PubTypes.Task})
	if xtypeof(refState) ~= "State" or refState.kind ~= "Value" then
		logError("invalidRefType")
	else
		refState:set(applyToRef.instance)
		table.insert(cleanupTasks, function()
			refState:set(nil)
		end)
	end
end

return Ref