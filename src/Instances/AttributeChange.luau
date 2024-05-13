--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	A special key for property tables, which allows users to connect to
	an attribute change on an instance.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)

local keyCache: {[string]: Types.SpecialKey} = {}

local function AttributeChange(
	attributeName: string
): Types.SpecialKey
	local key = keyCache[attributeName]
	if key == nil then
		key = {
			type = "SpecialKey",
			kind = "AttributeChange",
			stage = "observer",
			apply = function(
				self: Types.SpecialKey,
				scope: Types.Scope<unknown>,
				value: unknown,
				applyTo: Instance
			)
				if typeof(value) ~= "function" then
					External.logError("invalidAttributeChangeHandler", nil, attributeName)
				end
				local value = value :: (...unknown) -> (...unknown)
				local event = applyTo:GetAttributeChangedSignal(attributeName)
				table.insert(scope, event:Connect(function()
					value((applyTo :: any):GetAttribute(attributeName))
				end))
			end
		}
		keyCache[attributeName] = key
	end
	return key
end

return AttributeChange