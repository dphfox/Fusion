--!strict

--[[
	A special key for property tables, which allows users to connect to
	an attribute change on an instance.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logError = require(Package.Logging.logError)

local function AttributeChange(attributeName: string): PubTypes.SpecialKey
	if attributeName == nil then
		logError("attributeNameNil")
	end
	
	return {
		type = "SpecialKey",
		kind = "AttributeChange",
		stage = "observer",
		apply = function(
			self: PubTypes.SpecialKey,
			scope: PubTypes.Scope<any>,
			value: any,
			applyTo: Instance
		)
			if typeof(value) ~= "function" then
				logError("invalidAttributeChangeHandler", nil, attributeName)
			end
			local ok, event = pcall(applyTo.GetAttributeChangedSignal, applyTo, attributeName)
			if not ok then
				logError("cannotConnectAttributeChange", nil, applyTo.ClassName, attributeName)
			else
				value((applyTo :: any):GetAttribute(attributeName))
				table.insert(scope, event:Connect(function()
					value((applyTo :: any):GetAttribute(attributeName))
				end))
			end
		end
	}
end

return AttributeChange