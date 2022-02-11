--!strict

--[[
	Constructs and returns a new instance, with options for setting properties,
	event handlers and other attributes on the instance right away.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local defaultProps = require(Package.Instances.defaultProps)
local semiWeakRef = require(Package.Instances.semiWeakRef)
local applyInstanceProps = require(Package.Instances.applyInstanceProps)
local logError= require(Package.Logging.logError)

<<<<<<< HEAD
local function New(target: string | Instance)
	return function(propertyTable: PubTypes.PropertyTable): Instance
		-- things to clean up when the instance is destroyed or gc'd
		local cleanupTasks = {}
		-- event handlers to connect
		local toConnect: {[RBXScriptSignal]: () -> ()} = {}

		--[[
			STEP 1: Create a reference to a new instance
		]]
		local refMetatable = {__mode = ""}
		local ref = setmetatable({}, refMetatable)
		local conn

		do
			local instance
			local className
			local t = typeof(target)
			if t == 'string' then -- traditional string call
				className = target
				local createOK
				createOK, instance = pcall(Instance.new, className)
				if not createOK then
					logError("cannotCreateClass", nil, className)
				end
			elseif t == 'Instance' then -- support mounting
				className = Instance.ClassName
				instance = target
			else
				logError("unacceptableType", nil, t)
			end

			local defaultClassProps = defaultProps[className]
			if defaultClassProps ~= nil then
				for property, value in pairs(defaultClassProps) do
					instance[property] = value
				end
			end
=======
local function New(className: string)
	return function(props: PubTypes.PropertyTable): Instance
		local ok, instance = pcall(Instance.new, className)
>>>>>>> 6e95b42e1907fb4429d60d4702ebc4827d4ad10b

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