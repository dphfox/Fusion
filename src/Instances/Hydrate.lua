--!strict

--[[
	Processes and returns an existing instance, with options for setting
	properties, event handlers and other attributes on the instance.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.Instances.PubTypes)
local semiWeakRef = require(Package.Instances.semiWeakRef)
local applyInstanceProps = require(Package.Instances.applyInstanceProps)

local function Hydrate(target: Instance)
	return function(props: PubTypes.PropertyTable): Instance
		applyInstanceProps(props, semiWeakRef(target))
		return target
	end
end

return Hydrate