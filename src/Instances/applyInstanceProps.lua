--!strict

--[[
	Applies a table of properties to an instance, including binding to any
	given state objects and applying any special keys.

	No strong reference is kept by default - special keys should take care not
	to accidentally hold strong references to instances forever.

	If a key is used twice, an error will be thrown. This is done to avoid
	double assignments or double bindings. However, some special keys may want
	to enable such assignments - in which case unique keys should be used for
	each occurence.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local PubTypes = require(Package.PubTypes)
local semiWeakRef = require(Package.Instances.semiWeakRef)
local logError = require(Package.Logging.logError)
local parseError = require(Package.Logging.parseError)

-- this is passed to xpcall later for safe property setting
local function setProperty(instance: Instance, property: string, value: any)
	(instance :: any)[property] = value
end

local function isPropertyAssignable(instance: Instance, property: string)
	return pcall(function()
		instance[property] = instance[property]
	end)
end

local function applyInstanceProps_impl(props: PubTypes.PropertyTable, applyToRef: PubTypes.SemiWeakRef)
	-- stage 1: configure self
	--     properties
	-- stage 2: configure descendants
	--     Children
	-- stage 3: configure ancestor
	--     Parent
	-- stage 4: configure observers
	--     Ref
	--     OnEvent / OnChange

	-- TODO: type this
	local specialKeys = {
		self = {},
		descendants = {},
		ancestor = {},
		observer = {}
	}

	local parentTo: Instance? = nil
	-- TODO: when do we connect to cleanupOnDestroy?
	local cleanupTasks = {}

	for key, value in pairs(props) do
		if key == "Parent" then
			-- the only string key we need to save for later (the ancestor step)
			parentTo = value
		elseif typeof(key) == "string" then
			-- apply any other string keys as properties directly
			local ok, result = xpcall(setProperty, parseError, applyToRef.instance, key, value)
			if not ok then
				-- handle incorrect property assignments
				local result = result :: Types.Error
				local className = applyToRef.instance.ClassName

				if isPropertyAssignable(applyToRef.instance, key) then
					-- gave a value of a different type
					local givenType = typeof(value)
					local expectedType = typeof((applyToRef.instance :: any)[key])
					logError("invalidPropertyType", result, givenType, expectedType, className)
				else
					-- setting a property that doesn't exist or can't be set
					logError("cannotAssignProperty", result, className, key)
				end
			end
		elseif typeof(key) == "table" and key.type == "SpecialKey" then
			-- unmix special keys into their appropriate stages
			-- TODO: type this
			local keys = specialKeys[key.stage]

			if keys == nil then
				logError("unrecognisedPropertyStage", nil, key.stage)
			else
				keys[key] = value
			end
		else
			-- we don't recognise what this key is supposed to be
			local keyString = typeof(key)
			if keyString == "table" and typeof(key.type) == "string" then
				keyString = key.type
			end
			logError("unrecognisedPropertyKey", nil, keyString)
		end
	end

	local function applySpecialKeys(keys)
		for key, value in pairs(keys) do
			key:apply(value, applyToRef, cleanupTasks)
		end
	end

	applySpecialKeys(specialKeys.self)
	applySpecialKeys(specialKeys.descendants)
	;(applyToRef.instance :: Instance).Parent = parentTo
	applySpecialKeys(specialKeys.ancestor)
	applySpecialKeys(specialKeys.observer)
end

local function applyInstanceProps(props: PubTypes.PropertyTable, applyTo: Instance)
	applyInstanceProps_impl(props, semiWeakRef(applyTo))
end

return applyInstanceProps