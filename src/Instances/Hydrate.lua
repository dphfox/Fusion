--!strict

--[[
	Processes and returns an existing instance, with options for setting
	properties, event handlers and other attributes on the instance.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local applyInstanceProps = require(Package.Instances.applyInstanceProps)

local function Hydrate(
	scope: PubTypes.Scope<any>,
	target: Instance
)
	return function(
		props: PubTypes.PropertyTable
	): Instance
	
		table.insert(scope, target)
		applyInstanceProps(scope, props, target)
		return target
	end
end

return Hydrate