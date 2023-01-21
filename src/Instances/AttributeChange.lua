--!strict

--[[
	A special key for property tables, which allows users to connect to
    an attribute change on an instance.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logError = require(Package.Logging.logError)
local xtypeof = require(Package.Utility.xtypeof)

local function AttributeChanged(attributeName: string): PubTypes.SpecialKey
	local attributeKey = {}
	attributeKey.type = "SpecialKey"
	attributeKey.kind = "AttributeChange"
	attributeKey.stage = "observer"

    function attributeKey:apply(callback: any, applyTo: Instance, cleanupTasks: {PubTypes.Task})
        local ok, event = pcall(applyTo.GetAttributeChangedSignal, applyTo, attributeName)
		if not ok then
			logError("cannotConnectAttributeChange", nil, applyTo.ClassName, attributeName)
		elseif typeof(callback) ~= "function" then
			logError("invalidAttributeChangeHandler", nil, attributeName)
		else
			callback((applyTo :: any):GetAttribute(attributeName))
			table.insert(cleanupTasks, event:Connect(function()
				callback((applyTo :: any):GetAttribute(attributeName))
			end))
		end
    end

	return attributeKey
end

return AttributeChanged
