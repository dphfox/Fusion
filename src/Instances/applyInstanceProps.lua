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
local PubTypes = require(Package.Instances.PubTypes)
local onDestroy = require(Package.Instances.onDestroy)
local cleanup = require(Package.Core.Utility.cleanup)
local xtypeof = require(Package.Core.Utility.xtypeof)
local logError = require(Package.Core.Logging.logError)
local logWarn = require(Package.Core.Logging.logWarn)
local Observer = require(Package.State.Observer)

local function setProperty_unsafe(instance: Instance, property: string, value: any)
	(instance :: any)[property] = value
end

local function testPropertyAssignable(instance: Instance, property: string)
	(instance :: any)[property] = (instance :: any)[property]
end

local function setProperty(instance: Instance, property: string, value: any)
	if not pcall(setProperty_unsafe, instance, property, value) then
		if not pcall(testPropertyAssignable, instance, property) then
			if instance == nil then
				-- reference has been lost
				logError("setPropertyNilRef", nil, property, tostring(value))
			else
				-- property is not assignable
				logError("cannotAssignProperty", nil, instance.ClassName, property)
			end
		else
			-- property is assignable, but this specific assignment failed
			-- this typically implies the wrong type was received
			local givenType = typeof(value)
			local expectedType = typeof((instance :: any)[property])
			logError("invalidPropertyType", nil, instance.ClassName, property, expectedType, givenType)
		end
	end
end

local function bindProperty(instanceRef: PubTypes.SemiWeakRef, property: string, value: PubTypes.CanBeState<any>, cleanupTasks: {PubTypes.Task})
	if xtypeof(value) == "State" then
		-- value is a state object - assign and observe for changes
		local willUpdate = false
		local function updateLater()
			if not willUpdate then
				willUpdate = true
				task.defer(function()
					willUpdate = false
					setProperty(instanceRef.instance :: Instance, property, value:get(false))
				end)
			end
		end

		setProperty(instanceRef.instance :: Instance, property, value:get(false))
		table.insert(cleanupTasks, Observer(value :: any):onChange(updateLater))
	else
		-- value is a constant - assign once only
		setProperty(instanceRef.instance :: Instance, property, value)
	end
end

local function applyInstanceProps(props: PubTypes.PropertyTable, applyToRef: PubTypes.SemiWeakRef)
	if applyToRef.instance == nil then
		-- this is possible, but not useful, so probably indicates an issue!
		return logWarn("applyPropsNilRef")
	end

	local specialKeys = {
		self = {} :: {[PubTypes.SpecialKey]: any},
		descendants = {} :: {[PubTypes.SpecialKey]: any},
		ancestor = {} :: {[PubTypes.SpecialKey]: any},
		observer = {} :: {[PubTypes.SpecialKey]: any}
	}
	local cleanupTasks = {}

	for key, value in pairs(props) do
		local keyType = xtypeof(key)

		if keyType == "string" then
			if key ~= "Parent" then
				bindProperty(applyToRef, key :: string, value, cleanupTasks)
			end
		elseif keyType == "SpecialKey" then
			local stage = (key :: PubTypes.SpecialKey).stage
			local keys = specialKeys[stage]
			if keys == nil then
				logError("unrecognisedPropertyStage", nil, stage)
			else
				keys[key] = value
			end
		else
			-- we don't recognise what this key is supposed to be
			logError("unrecognisedPropertyKey", nil, xtypeof(key))
		end
	end

	for key, value in pairs(specialKeys.self) do
		key:apply(value, applyToRef, cleanupTasks)
	end
	for key, value in pairs(specialKeys.descendants) do
		key:apply(value, applyToRef, cleanupTasks)
	end

	if props.Parent ~= nil then
		bindProperty(applyToRef, "Parent", props.Parent, cleanupTasks)
	end

	for key, value in pairs(specialKeys.ancestor) do
		key:apply(value, applyToRef, cleanupTasks)
	end
	for key, value in pairs(specialKeys.observer) do
		key:apply(value, applyToRef, cleanupTasks)
	end

	onDestroy(applyToRef, cleanup, cleanupTasks)
end

return applyInstanceProps