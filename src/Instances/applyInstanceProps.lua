--!strict

--[[
	Applies a table of properties to an instance, including binding to any
	given state objects and applying any special keys.

	No strong reference is kept by default - special keys should take care not
	to accidentally hold strong references to instances forever.

	If a property of an instance is assigned to twice, an error will be raised.
	It's encouraged for special keys to do the same where multiple assignment
	doesn't make sense.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Types = require(Package.Types)
local semiWeakRef = require(Package.Instances.semiWeakRef)



local function applyInstanceProps_impl(props: PubTypes.PropertyTable, applyToRef: Types.SemiWeakRef)
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

local function applyInstanceProps(props: PubTypes.PropertyTable, applyTo: Instance)
	applyInstanceProps_impl(props, semiWeakRef(applyTo))
end

return applyInstanceProps