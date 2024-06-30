

--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	Procedures for checking lifetimes and printing helpful warnings about them.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
local whichLivesLonger = require(Package.Memory.whichLivesLonger)
local nameOf = require(Package.Utility.nameOf)

local checkLifetime = {}

checkLifetime.formatters = {}

function checkLifetime.formatters.useFunction(
	self: unknown,
	used: unknown
): (string, string)
	local selfName = nameOf(self, "object")
	local usedName = nameOf(used, "object")
	return `The use()-d {usedName}`, `the {selfName}`
end
	
function checkLifetime.formatters.boundProperty(
	instance: Instance,
	bound: unknown,
	property: string
): (string, string)
	local selfName = instance.Name
	local boundName = nameOf(bound, "value")
	return `The {boundName} (bound to the {property} property)`, `the {selfName} instance`
end

function checkLifetime.formatters.boundAttribute(
	instance: Instance,
	bound: unknown,
	attribute: string
): (string, string)
	local selfName = instance.Name
	local boundName = nameOf(bound, "value")
	return `The {boundName} (bound to the {attribute} attribute)`, `the {selfName} instance`
end

function checkLifetime.formatters.propertyOutputsTo(
	instance: Instance,
	bound: unknown,
	property: string
): (string, string)
	local selfName = instance.Name
	local boundName = nameOf(bound, "object")
	return `The {boundName} (which the {property} property outputs to)`, `the {selfName} instance`
end

function checkLifetime.formatters.attributeOutputsTo(
	instance: Instance,
	bound: unknown,
	attribute: string
): (string, string)
	local selfName = instance.Name
	local boundName = nameOf(bound, "object")
	return `The {boundName} (which the {attribute} attribute outputs to)`, `the {selfName} instance`
end

function checkLifetime.formatters.refOutputsTo(
	instance: Instance,
	bound: unknown
): (string, string)
	local selfName = instance.Name
	local boundName = nameOf(bound, "object")
	return `The {boundName} (which the Ref key outputs to)`, `the {selfName} instance`
end

function checkLifetime.formatters.animationGoal(
	self: unknown,
	goal: unknown
): (string, string)
	local selfName = nameOf(self, "object")
	local goalName = nameOf(goal, "object")
	return `The goal {goalName}`, `the {selfName} that is following it`
end

function checkLifetime.formatters.parameter(
	self: unknown,
	used: unknown,
	parameterName: string | false
): (string, string)
	local selfName = nameOf(self, "object")
	local usedName = nameOf(used, "object")
	if parameterName == false then
		return `The {usedName} parameter`, `the {selfName} that it was used for`
	else
		return `The {usedName} representing the {parameterName} parameter`, `the {selfName} that it was used for`
	end
end

function checkLifetime.formatters.observer(
	self: unknown,
	watched: unknown
): (string, string)
	local selfName = nameOf(self, "object")
	local watchedName = nameOf(watched, "object")
	return `The watched {watchedName}`, `the {selfName} that's observing it for changes`
end

function checkLifetime.bOutlivesA<A, B, Args...>(
	scopeA: Types.Scope<unknown>,
	a: A,
	scopeB: Types.Scope<unknown>?,
	b: B,
	formatter: (a: A, b: B, Args...) -> (string, string),
	...: Args...
)
	if scopeB == nil then
		External.logError("useAfterDestroy", nil, formatter(a, b, ...))
	elseif whichLivesLonger(scopeA, a, scopeB, b) == "definitely-a" then
		local aName, bName = formatter(a, b, ...)
		External.logWarn(
			"possiblyOutlives",
			aName, bName, 
			if scopeA == scopeB then
				"they're in the same scope, but the latter is destroyed too quickly"
			else
				"the latter is in a different scope that gets destroyed too quickly"
		)
	end
end
return checkLifetime