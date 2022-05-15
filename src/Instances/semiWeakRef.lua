--!strict

--[[
	Returns a semi-weak reference to the given instance:

	- the reference acts like a strong reference when the instance can be
	accessed via the data model (see `isAccessible.lua`)
	- the reference acts like a weak reference otherwise

	This allows users to have a stable reference to an instance, while allowing
	the garbage collector to collect it when other users dispose of it.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.Instances.PubTypes)
local isAccessible = require(Package.Instances.isAccessible)

local WEAK_MODE = { __mode = "v" }
local STRONG_MODE = { __mode = "" }

-- Because the semi-weak refs are stored strongly here, the instance keys won't
-- garbage collect unless the semi-weak ref is weak, which only occurs when the
-- instance is not accessible.
local cachedRefs: {[Instance]: PubTypes.SemiWeakRef} = {}
setmetatable(cachedRefs, { __mode = "k"})

local function semiWeakRef_impl(strongReferTo: Instance?): PubTypes.SemiWeakRef
	if strongReferTo == nil then
		return {type = "SemiWeakRef", instance = nil}
	else
		if cachedRefs[strongReferTo] then
			return cachedRefs[strongReferTo]
		end

		local ref: PubTypes.SemiWeakRef = {
			type = "SemiWeakRef",
			instance = strongReferTo
		}
		cachedRefs[strongReferTo] = ref

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
end

local semiWeakRef = (semiWeakRef_impl :: any) :: (referTo: Instance) -> PubTypes.SemiWeakRef

return semiWeakRef