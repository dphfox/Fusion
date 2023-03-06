--[[
	Binds a value to a given property of a Instance, which allows the user to
	bind State Objects to instances not managed by Fusion.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Observer = require(Package.State.Observer)
local peek = require(Package.State.peek)
local xtypeof = require(Package.Utility.xtypeof)
local logError = require(Package.Logging.logError)
local doNothing = require(Package.Utility.doNothing)

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

local function BindProperty(instance: Instance, property: string, value: PubTypes.CanBeState<any>)
	if xtypeof(value) == "State" then
		-- value is a state object - assign and observe for changes
		local willUpdate = false
		local function updateLater()
			if not willUpdate then
				willUpdate = true
				task.defer(function()
					willUpdate = false
					setProperty(instance, property, peek(value))
				end)
			end
		end

		setProperty(instance, property, peek(value))
		
		return Observer(value :: any):onChange(updateLater)
	else
		-- value is a constant - assign once only
		setProperty(instance, property, value)
		
		return doNothing
	end
end

return BindProperty