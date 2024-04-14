--!strict
--!nolint LocalShadow

--[[
	A special key for property tables, which allows users to connect to
	an attribute change on an instance.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logError = require(Package.Logging.logError)

local function AttributeChange(
	attributeName: string
): Types.SpecialKey
	return {
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
				logError("invalidAttributeChangeHandler", nil, attributeName)
			end
			local value = value :: (...unknown) -> (...unknown)
			local event = applyTo:GetAttributeChangedSignal(attributeName)
			value((applyTo :: any):GetAttribute(attributeName))
			table.insert(scope, event:Connect(function()
				value((applyTo :: any):GetAttribute(attributeName))
			end))
		end
	}
end

return AttributeChange