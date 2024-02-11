--!strict

--[[
	A special key for property tables, which assigns CollectionService tags
	to instances.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logWarn = require(Package.Logging.logWarn)
local xtypeof = require(Package.Utility.xtypeof)

local Tags = {}
Tags.type = "SpecialKey"
Tags.kind = "Tags"
Tags.stage = "observer"

function Tags:apply(tags: any, applyTo: Instance, cleanupTasks: {PubTypes.Task})
	
end

return Tags :: PubTypes.SpecialKey