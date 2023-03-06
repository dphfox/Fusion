--[[
	A function used to plug into a existing instance's property and read it.
]]

local Package = script.Parent.Parent
local Value = require(Package.State.Value)
local Computed = require(Package.State.Computed)
local logError = require(Package.Logging.logError)
local xtypeof = require(Package.Utility.xtypeof)
local doNothing = require(Package.Utility.doNothing)

local function PropertyOf<T>(of: Instance, property: string)
	
	if xtypeof(of) ~= "Instance" then
		logError("propertyOfInvalidInstance", nil, xtypeof(of))
	end
	
	if xtypeof(property) ~= "string" then
		logError("propertyOfInvalidName", nil, of.Name, property)
	end
	
	-- check if the property can be read from
	local ok, value = pcall(function()
		return of[property]
	end)
	
	if ok == false then
		logError("unknownProperty", nil, of.ClassName, property)
	end
	
	-- we'll create a Computed that wraps a normal Value object to create a
	-- "read-only" state object.
	local realValue = Value(value)
	
	-- FIXME: Lingering connection, how do we clean this up when the Computed
	--		  is no longer used? Only cleans up when of is destroyed.
	--		  Maybe we only have to return the actual property value itself.
	local connection = of:GetPropertyChangedSignal(property):Connect(function()
		realValue:set(of[property])
	end)
	
	return Computed(function(use)
		return use(realValue)
	end, doNothing)
	
end

return PropertyOf