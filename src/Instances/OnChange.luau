--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Constructs special keys for property tables which connect property change
	listeners to an instance.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)

local keyCache: {[string]: Types.SpecialKey} = {}

local function OnChange(
	propertyName: string
): Types.SpecialKey
	local key = keyCache[propertyName]
	if key == nil then
		key = {
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
					External.logError("cannotConnectChange", nil, applyTo.ClassName, propertyName)
				elseif typeof(callback) ~= "function" then
					External.logError("invalidChangeHandler", nil, propertyName)
				else
					local callback = callback :: (...unknown) -> (...unknown)
					table.insert(scope, event:Connect(function()
						callback((applyTo :: any)[propertyName])
					end))
				end
			end
		}
		keyCache[propertyName] = key
	end
	return key
end

return OnChange