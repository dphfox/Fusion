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
local PubTypes = require(Package.PubTypes)
local semiWeakRef = require(Package.Instances.semiWeakRef)
local onDestroy = require(Package.Instances.onDestroy)
local cleanup = require(Package.Utility.cleanup)
local logError = require(Package.Logging.logError)
local Observer = require(Package.State.Observer)

local function setProperty_unsafe(instance: Instance, property: string, value: any)
	(instance :: any)[property] = value
end

local function testPropertyAssignable(instance: Instance, property: string)
	instance[property] = instance[property]
end

local function setProperty(instance: Instance, property: string, value: any)
	-- try and set the property
	if not pcall(setProperty_unsafe, instance, property, value) then
		if not pcall(testPropertyAssignable, instance, property) then
			-- property is not assignable
			logError("cannotAssignProperty", nil, instance.ClassName, property)
		else
			-- property is assignable, but this specific assignment failed
			-- this typically implies the wrong type was received
			local givenType = typeof(value)
			local expectedType = typeof((instance :: any)[property])
			logError("invalidPropertyType", nil, givenType, expectedType, instance.ClassName)
		end
	end
end

local function bindProperty(instance: Instance, property: string, value: PubTypes.CanBeState<any>, cleanupTasks: {PubTypes.Task})
	if type(value) == "table" and value.type == "State" then
		-- value is a state object - assign and observe for changes
		local willUpdate = false
		local function updateLater()
			if not willUpdate then
				willUpdate = true
				task.defer(function()
					willUpdate = false
					setProperty(instance, property, value:get(false))
				end)
			end
		end

		setProperty(instance, property, value:get(false))
		table.insert(cleanupTasks, Observer(value):onChange(updateLater))
	else
		-- value is a constant - assign once only
		setProperty(instance, property, value)
	end
end

local function applyInstanceProps_impl(props: PubTypes.PropertyTable, applyToRef: PubTypes.SemiWeakRef)
	local specialKeys = {
		self = {} :: {[PubTypes.SpecialKey]: any},
		descendants = {} :: {[PubTypes.SpecialKey]: any},
		ancestor = {} :: {[PubTypes.SpecialKey]: any},
		observer = {} :: {[PubTypes.SpecialKey]: any}
	}

	local parentTo: Instance? = nil
	local cleanupTasks = {}

	for key, value in pairs(props) do
		if key == "Parent" then
			-- the only string key we need to save for later (the ancestor step)
			parentTo = value

		elseif typeof(key) == "string" then
			-- apply any other string keys as properties directly
			bindProperty(applyToRef.instance, key, value, cleanupTasks)

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

	for key, value in pairs(specialKeys.self) do
		key:apply(value, applyToRef, cleanupTasks)
	end
	for key, value in pairs(specialKeys.descendants) do
		key:apply(value, applyToRef, cleanupTasks)
	end
	bindProperty(applyToRef.instance, "Parent", parentTo, cleanupTasks)
	for key, value in pairs(specialKeys.ancestor) do
		key:apply(value, applyToRef, cleanupTasks)
	end
	for key, value in pairs(specialKeys.observer) do
		key:apply(value, applyToRef, cleanupTasks)
	end

	onDestroy(applyToRef, cleanup, cleanupTasks)
end

local function applyInstanceProps(props: PubTypes.PropertyTable, applyTo: Instance)
	applyInstanceProps_impl(props, semiWeakRef(applyTo))
end

return applyInstanceProps