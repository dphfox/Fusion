--!strict
--!nolint LocalShadow

--[[
	Processes and returns an existing instance, with options for setting
	properties, event handlers and other attributes on the instance.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local applyInstanceProps = require(Package.Instances.applyInstanceProps)
local logError = require(Package.Logging.logError)

local function Hydrate(
	scope: Types.Scope<unknown>,
	target: Instance
)
	if target :: any == nil then
		logError("scopeMissing", nil, "instances using Hydrate", "myScope:Hydrate (instance) { ... }")
	end
	return function(
		props: Types.PropertyTable
	): Instance
	
		table.insert(scope, target)
		applyInstanceProps(scope, props, target)
		return target
	end
end

return Hydrate