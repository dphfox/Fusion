--[[
	A function commonly used with templates to plug into a existing instance
	and get a certain child easily.
]]

local Package = script.Parent.Parent
local logError = require(Package.Logging.logError)
local xtypeof = require(Package.Utility.xtypeof)

local function ChildOfClass(of: Instance, className: string): Instance
	
	if xtypeof(of) ~= "Instance" then
		logError("childOfInvalidInstance", nil, xtypeof(of))
	end
	
	if xtypeof(className) ~= "string" then
		logError("childOfInvalidClassName", nil, of.Name, className)
	end
	
	local child = of:FindFirstChildWhichIsA(className)
	
	if child == nil then
		--TODO: Figure out if this is necessary?
		logError("unknownChildClassName", nil, of.Name, className)
	end
	
	return child
	
end

return ChildOfClass