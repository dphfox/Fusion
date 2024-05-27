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
<<<<<<< HEAD
local applyInstanceProps = require(Package.Instances.applyInstanceProps)
local logError = require(Package.Logging.logError)
=======
local External = require(Package.External)
local applyInstanceProps = require(Package.Instances.applyInstanceProps)
>>>>>>> upstream/main

local function Hydrate(
	scope: Types.Scope<unknown>,
	target: Instance
)
	if target :: any == nil then
<<<<<<< HEAD
		logError("scopeMissing", nil, "instances using Hydrate", "myScope:Hydrate (instance) { ... }")
=======
		External.logError("scopeMissing", nil, "instances using Hydrate", "myScope:Hydrate (instance) { ... }")
>>>>>>> upstream/main
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