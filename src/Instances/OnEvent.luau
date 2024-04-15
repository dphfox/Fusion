--!strict
--!nolint LocalShadow

--[[
	Constructs special keys for property tables which connect event listeners to
	an instance.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local logError = require(Package.Logging.logError)

local function getProperty_unsafe(
	instance: Instance,
	property: string
)
	return (instance :: any)[property]
end

local function OnEvent(
	eventName: string
): Types.SpecialKey
	return {
		type = "SpecialKey",
		kind = "OnEvent",
		stage = "observer",
		apply = function(
			self: Types.SpecialKey,
			scope: Types.Scope<unknown>,
			callback: unknown,
			applyTo: Instance
		)
			local ok, event = pcall(getProperty_unsafe, applyTo, eventName)
			if not ok or typeof(event) ~= "RBXScriptSignal" then
				logError("cannotConnectEvent", nil, applyTo.ClassName, eventName)
			elseif typeof(callback) ~= "function" then
				logError("invalidEventHandler", nil, eventName)
			else
				table.insert(scope, event:Connect(callback))
			end
		end
	}
end

return OnEvent