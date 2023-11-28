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
local doCleanup = require(Package.Memory.doCleanup)
local External = require(Package.External)
local isState = require(Package.State.isState)
local logError = require(Package.Logging.logError)
local Observer = require(Package.State.Observer)
local peek = require(Package.State.peek)
local xtypeof = require(Package.Utility.xtypeof)

local function setProperty_unsafe(
	instance: Instance,
	property: string,
	value: any
)
	(instance :: any)[property] = value
end

local function testPropertyAssignable(
	instance: Instance,
	property: string
)
	(instance :: any)[property] = (instance :: any)[property]
end

local function setProperty(
	instance: Instance,
	property: string,
	value: any
)
	if not pcall(setProperty_unsafe, instance, property, value) then
		if not pcall(testPropertyAssignable, instance, property) then
			logError("cannotAssignProperty", nil, instance.ClassName, property)
		else
			-- property is assignable, but this specific assignment failed
			-- this typically implies the wrong type was received
			local givenType = typeof(value)
			local expectedType = typeof((instance :: any)[property])
			logError("invalidPropertyType", nil, instance.ClassName, property, expectedType, givenType)
		end
	end
end

local function bindProperty(
	scope: PubTypes.Scope<any>,
	instance: Instance,
	property: string,
	value: PubTypes.CanBeState<any>
)
	if isState(value) then
		-- value is a state object - assign and observe for changes
		local willUpdate = false
		local function updateLater()
			if not willUpdate then
				willUpdate = true
				External.doTaskDeferred(function()
					willUpdate = false
					setProperty(instance, property, peek(value))
				end)
			end
		end

		setProperty(instance, property, peek(value))
		table.insert(scope, Observer(scope, value :: any):onChange(updateLater))
	else
		-- value is a constant - assign once only
		setProperty(instance, property, value)
	end
end

local function applyInstanceProps(
	scope: PubTypes.Scope<any>,
	props: PubTypes.PropertyTable,
	applyTo: Instance
)
	local specialKeys = {
		self = {} :: {[PubTypes.SpecialKey]: any},
		descendants = {} :: {[PubTypes.SpecialKey]: any},
		ancestor = {} :: {[PubTypes.SpecialKey]: any},
		observer = {} :: {[PubTypes.SpecialKey]: any}
	}

	for key, value in pairs(props) do
		local keyType = xtypeof(key)

		if keyType == "string" then
			if key ~= "Parent" then
				bindProperty(scope, applyTo, key :: string, value)
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
			logError("unrecognisedPropertyKey", nil, keyType)
		end
	end

	for key, value in pairs(specialKeys.self) do
		key:apply(scope, value, applyTo)
	end
	for key, value in pairs(specialKeys.descendants) do
		key:apply(scope, value, applyTo)
	end

	if props.Parent ~= nil then
		bindProperty(scope, applyTo, "Parent", props.Parent)
	end

	for key, value in pairs(specialKeys.ancestor) do
		key:apply(scope, value, applyTo)
	end
	for key, value in pairs(specialKeys.observer) do
		key:apply(scope, value, applyTo)
	end

	applyTo.Destroying:Connect(function()
		doCleanup(scope)
	end)
end

return applyInstanceProps