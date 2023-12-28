--!strict
--!nolint LocalShadow

--[[
	Constructs special keys for property tables which connect property change
	listeners to an instance.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logError = require(Package.Logging.logError)

local function OnChange(
	propertyName: string
): Types.SpecialKey
	return {
		type = "SpecialKey",
		kind = "OnChange",
		stage = "observer",
		apply = function(
			self: Types.SpecialKey,
			scope: Types.Scope<unknown>,
			callback: unknown,
			applyTo: Instance
		)
			local ok, event = pcall(applyTo.GetPropertyChangedSignal, applyTo, propertyName)
			if not ok then
				logError("cannotConnectChange", nil, applyTo.ClassName, propertyName)
			elseif typeof(callback) ~= "function" then
				logError("invalidChangeHandler", nil, propertyName)
			else
				local callback = callback :: (...unknown) -> (...unknown)
				table.insert(scope, event:Connect(function()
					callback((applyTo :: any)[propertyName])
				end))
			end
		end
	}
end

return OnChange