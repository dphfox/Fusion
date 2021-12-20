--!strict

--[[
	Constructs and returns a new instance, with options for setting properties,
	event handlers and other attributes on the instance right away.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)

local function New(className: string)
	return function(propertyTable: PubTypes.PropertyTable): Instance

		-- stage 1: configure self
		--     properties
		-- stage 2: configure descendants
		--     Children
		-- stage 3: configure ancestor
		--     Parent
		-- stage 4: configure observers
		--     Ref
		--     OnEvent / OnChange


		-- TODO: implement this
	end
end

return New