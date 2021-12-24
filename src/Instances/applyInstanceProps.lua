--!strict

--[[
	Applies a table of properties to an instance, including binding to any
	given state objects and applying any special keys.

	No strong reference is kept by default - special keys should take care not
	to accidentally hold strong references to instances forever.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)

local function applyInstanceProps(props: PubTypes.PropertyTable, applyTo: Instance)
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

return applyInstanceProps