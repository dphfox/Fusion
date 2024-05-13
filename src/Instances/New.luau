--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Constructs and returns a new instance, with options for setting properties,
	event handlers and other attributes on the instance right away.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
local defaultProps = require(Package.Instances.defaultProps)
local applyInstanceProps = require(Package.Instances.applyInstanceProps)

type Component = (Types.PropertyTable) -> Instance

local componentCache: {[string]: Component} = {}

local function New(
	scope: Types.Scope<unknown>,
	className: string
)
	if (className :: any) == nil then
		local scope = (scope :: any) :: string
		External.logError("scopeMissing", nil, "instances using New", "myScope:New \"" .. scope .. "\" { ... }")
	end

	local component = componentCache[className]
	if component == nil then
		component = function(
			props: Types.PropertyTable
		): Instance
			local ok, instance = pcall(Instance.new, className)
			if not ok then
				External.logError("cannotCreateClass", nil, className)
			end

			local classDefaults = defaultProps[className]
			if classDefaults ~= nil then
				for defaultProp, defaultValue in pairs(classDefaults) do
					(instance :: any)[defaultProp] = defaultValue
				end
			end

			table.insert(scope, instance)
			applyInstanceProps(scope, props, instance)

			return instance
		end
		componentCache[className] = component
	end
	return component
end

return New