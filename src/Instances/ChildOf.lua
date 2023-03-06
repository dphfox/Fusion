--[[
	A function commonly used with templates to plug into a existing instance
	and get a certain child easily.
]]

local Package = script.Parent.Parent
local logError = require(Package.Logging.logError)
local xtypeof = require(Package.Utility.xtypeof)

local function ChildOf(of: Instance, name: string): Instance
	
	if xtypeof(of) ~= "Instance" then
		logError("childOfInvalidInstance", nil, xtypeof(of))
	end
	
	if xtypeof(name) ~= "string" then
		logError("childOfInvalidName", nil, of.Name, name)
	end
	
	local child = of:FindFirstChild(name)
	if child == nil then
		--TODO: Figure out if this is necessary?
		logError("unknownChildName", nil, of.Name, name)
	end
	
	return child
	
end

return ChildOf