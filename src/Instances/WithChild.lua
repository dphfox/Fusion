--[[
	Based off of initial proposal in https://github.com/Elttob/Fusion/issues/124
	Here are some assumptions I made while writing this:
		- We use FindFirstChild
			This is because the intended use for this is with templates where
			all the children are already cloned.
		- We mean the "Thing" at the current time
			I don't believe you should change names of instances when they
			already exist and are named when creating the initial template.
		- No selectors
			it's midnight while writing this
	
	This is based off of a issue which is not yet marked as approved.
	The actual part where we assign and work with the instance is to be done
	inside the Children SpecialKey.
]]

local Package = script.Parent.Parent

local PubTypes = require(Package.PubTypes)

local function WithChild(instanceName: string)
	
	return function(properties: PubTypes.PropertyTable)
		
		return {
			type = "SpecialChild",
			kind = "",
			
			name = instanceName,
			properties = properties
		}
		
	end
	
end

return WithChild