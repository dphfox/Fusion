--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

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
local External = require(Package.External)
-- Logging
local parseError = require(Package.Logging.parseError)
-- Memory
local checkLifetime = require(Package.Memory.checkLifetime)
-- Graph
local Observer = require(Package.Graph.Observer)
-- State
local castToState = require(Package.State.castToState)
local peek = require(Package.State.peek)
-- Utility
local xtypeof = require(Package.Utility.xtypeof)

local function setProperty_unsafe(
	instance: Instance,
	property: string,
	value: unknown
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
	value: unknown
)
	local success, err = xpcall(setProperty_unsafe :: any, parseError, instance, property, value)

	if not success then
		if not pcall(testPropertyAssignable, instance, property) then
			External.logErrorNonFatal("cannotAssignProperty", nil, instance.ClassName, property)
		else
			-- property is assignable, but this specific assignment failed
			-- this typically implies the wrong type was received
			local givenType = typeof(value)
			local expectedType = typeof((instance :: any)[property])

			if givenType == expectedType then
				External.logErrorNonFatal("propertySetError", err)
			else
				External.logErrorNonFatal("invalidPropertyType", nil, instance.ClassName, property, expectedType, givenType)
			end
		end
	end
end

local function bindProperty(
	scope: Types.Scope<unknown>,
	instance: Instance,
	property: string,
	value: Types.UsedAs<unknown>
)
	if castToState(value) then
		local value = value :: Types.StateObject<unknown>
		checkLifetime.bOutlivesA(
			scope, instance,
			value.scope, value.oldestTask,
			checkLifetime.formatters.boundProperty, property
		)
		-- value is a state object - bind to changes
		Observer(scope, value :: any):onBind(function()
			setProperty(instance, property, peek(value))
		end)
	else
		-- value is a constant - assign once only
		setProperty(instance, property, value)
	end
end

local function applyInstanceProps(
	scope: Types.Scope<unknown>,
	props: Types.PropertyTable,
	applyTo: Instance
)
	local specialKeys = {
		self = {} :: {[Types.SpecialKey]: unknown},
		descendants = {} :: {[Types.SpecialKey]: unknown},
		ancestor = {} :: {[Types.SpecialKey]: unknown},
		observer = {} :: {[Types.SpecialKey]: unknown}
	}

	for key, value in pairs(props) do
		local keyType = xtypeof(key)

		if keyType == "string" then
			if key ~= "Parent" then
				bindProperty(scope, applyTo, key :: string, value)
			end
		elseif keyType == "SpecialKey" then
			local stage = (key :: Types.SpecialKey).stage
			local keys = specialKeys[stage]
			if keys == nil then
				External.logError("unrecognisedPropertyStage", nil, stage)
			else
				keys[key] = value
			end
		else
			-- we don't recognise what this key is supposed to be
			External.logError("unrecognisedPropertyKey", nil, keyType)
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
end

return applyInstanceProps