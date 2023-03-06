--!strict

--[[
	Constructs and returns a new instance or clones a template, with options
	for setting properties, event handlers and other attributes on the instance
	right away.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local defaultProps = require(Package.Instances.defaultProps)
local applyInstanceProps = require(Package.Instances.applyInstanceProps)
local logError = require(Package.Logging.logError)

local function New(classNameOrTemplate: string | Instance)
	
	return function(props: PubTypes.PropertyTable)
		
		local target: Instance
		
		if typeof(classNameOrTemplate) == "Instance" then
			target = classNameOrTemplate:Clone()
			
		elseif typeof(classNameOrTemplate) == "string" then
			
			local ok, instance = pcall(Instance.new, classNameOrTemplate)

			if not ok then
				logError("cannotCreateClass", nil, classNameOrTemplate)
			end
			
			local classDefaults = defaultProps[classNameOrTemplate]
			if classDefaults ~= nil then
				for defaultProp, defaultValue in pairs(classDefaults) do
					instance[defaultProp] = defaultValue
				end
			end
			
			target = instance
			
		else
			logError("cannotCreateOrHydrate", nil, tostring(classNameOrTemplate))
		end
		
		applyInstanceProps(props, target)
		
		return target
		
	end
	
end

return New