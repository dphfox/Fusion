--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Constructs special keys for property tables which connect event listeners to
	an instance.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)

local keyCache: {[string]: Types.SpecialKey} = {}

local function getProperty_unsafe(
	instance: Instance,
	property: string
)
	return (instance :: any)[property]
end

local function OnEvent(
	eventName: string
): Types.SpecialKey
	local key = keyCache[eventName]
	if key == nil then
		key = {
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
					External.logError("cannotConnectEvent", nil, applyTo.ClassName, eventName)
				elseif typeof(callback) ~= "function" then
					External.logError("invalidEventHandler", nil, eventName)
				else
					table.insert(scope, event:Connect(callback :: any))
				end
			end
		}
		keyCache[eventName] = key
	end
	return key
end

return OnEvent