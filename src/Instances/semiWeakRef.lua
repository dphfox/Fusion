--!strict

--[[
	Returns a new semi-weak reference to the given instance:

	- the reference acts like a strong reference when the instance can be
	accessed via the data model (see `isAccessible.lua`)
	- the reference acts like a weak reference otherwise

	This allows users to have a stable reference to an instance, while allowing
	the garbage collector to collect it when other users dispose of it.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local isAccessible = require(Package.Instances.isAccessible)

local WEAK_MODE = { __mode = "v" }
local STRONG_MODE = { __mode = "" }

local function semiWeakRef_impl(strongReferTo: Instance?): Types.SemiWeakRef
	local ref: Types.SemiWeakRef = { instance = strongReferTo }
	-- we don't want a strong reference lingering around in any closures here
	strongReferTo = nil

	local function updateStrength()
		if ref.instance ~= nil then
			setmetatable(ref, if isAccessible(ref.instance) then STRONG_MODE else WEAK_MODE)
		end
	end

	(ref.instance :: Instance).AncestryChanged:Connect(updateStrength)
	task.defer(updateStrength)

	return ref
end

local semiWeakRef = semiWeakRef_impl :: (referTo: Instance) -> Types.SemiWeakRef

return semiWeakRef