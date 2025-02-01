--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Processes and returns an existing instance, with options for setting
	properties, event handlers and other attributes on the instance.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local applyInstanceProps = require(Package.Instances.applyInstanceProps)

local function Hydrate(
	scope: Types.Scope<unknown>,
	target: Instance
)
	return function(
		props: Types.PropertyTable
	): Instance
	
		table.insert(scope, target)
		applyInstanceProps(scope, props, target)
		return target
	end
end

return Hydrate