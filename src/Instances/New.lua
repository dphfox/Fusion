--!strict

--[[
	Constructs and returns a new instance, with options for setting properties,
	event handlers and other attributes on the instance right away.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.Instances.PubTypes)
local defaultProps = require(Package.Instances.defaultProps)
local semiWeakRef = require(Package.Instances.semiWeakRef)
local applyInstanceProps = require(Package.Instances.applyInstanceProps)
local logError= require(Package.Core.Logging.logError)

local function New(className: string)
	return function(props: PubTypes.PropertyTable): Instance
		local ok, instance = pcall(Instance.new, className)

		if not ok then
			logError("cannotCreateClass", nil, className)
		end

		local classDefaults = defaultProps[className]
		if classDefaults ~= nil then
			for defaultProp, defaultValue in pairs(classDefaults) do
				instance[defaultProp] = defaultValue
			end
		end

		applyInstanceProps(props, semiWeakRef(instance))

		return instance
	end
end

return New