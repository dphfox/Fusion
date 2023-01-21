--!strict

--[[
	A special key for property tables, which allows users to apply custom
    attributes to instances
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logError = require(Package.Logging.logError)
local xtypeof = require(Package.Utility.xtypeof)
local Observer = require(Package.State.Observer)

local function setAttribute(instance: Instance, attribute: string, value: any)
    instance:SetAttribute(attribute, value)
end

local function bindAttribute(instance: Instance, attribute: string, value: any, cleanupTasks: {PubTypes.Task})
    if xtypeof(value) == "State" then
		setAttribute(instance, attribute, value:get(false))
		table.insert(cleanupTasks, Observer(value :: any):onChange(function()
            setAttribute(instance, attribute, value:get(false))
        end))
    else
        setAttribute(instance, attribute, value)
    end
end

local function Attribute(attributeName: string)
    local AttributeKey = {}
    AttributeKey.type = "SpecialKey"
    AttributeKey.kind = "Attribute"
    AttributeKey.stage = "self"

    function AttributeKey:apply(attributeValue: any, applyTo: Instance, cleanupTasks: {PubTypes.Task})
        --[[
            [Attribute "Test"] = "Hi",
            [Attribute "Test"] = ammo,
            [Attribute "Test"] = Computed(function()
                return loaded:get() and 50 or 75
            end)
        ]]
        
        bindAttribute(applyTo, attributeName, attributeValue, cleanupTasks)
    end
    return AttributeKey
end

return Attribute