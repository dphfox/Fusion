--!strict

--[[
    Constructs special keys for property tables which connect event listeners to
    an instance.
]]

local Package = script.Parent.Parent.Lib
local PubTypes = require(Package.PubTypes)
local logError = require(Package.Logging.logError)

local function OnTick(hourglass: any): PubTypes.SpecialKey
    local eventKey = {}
    eventKey.type = "SpecialKey"
    eventKey.kind = "Hourglass"
    eventKey.stage = "observer"

    function eventKey:apply(callback: any, applyTo: Instance, cleanupTasks: {PubTypes.Task})
        if typeof(hourglass) == "table" and hourglass.ClassName == "Hourglass" and hourglass.Tick then
            table.insert(cleanupTasks, hourglass.Tick:Connect(callback))
        else logError("missingOrInvalidHourglass", nil, typeof(hourglass))
        end
    end

    return eventKey
end

return OnTick