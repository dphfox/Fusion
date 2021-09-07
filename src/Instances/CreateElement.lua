local Package = script.Parent.Parent

local Children = require(Package.Instances.Children)
local New = require(Package.Instances.New)
local Types = require(Package.Types)
local logError = require(Package.Logging.logError)

type ElementFunction = (properties: any?) -> Instance

local function CreateElement(
	element: string | ElementFunction,
	properties: {[string | Types.Symbol]: any}?,
	children: {Instance}?
)
	if not properties then
		properties = {}
	end

	if children ~= nil then
		properties[Children] = children
	end

	local elementType = typeof(element)
	if elementType == "string" then
		return New(element)(properties)
	elseif elementType == "function" then
		return (element :: ElementFunction)(properties)
	else
		logError("cannotCreateClassWithType", nil, tostring(element), elementType)
	end
end

return CreateElement
