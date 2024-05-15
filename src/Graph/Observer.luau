--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

--[[
	A graph object that runs user code when it's updated by the reactive graph.

	http://elttob.uk/Fusion/0.3/api-reference/state/types/observer/
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local External = require(Package.External)
-- Memory
local whichLivesLonger = require(Package.Memory.whichLivesLonger)
-- Graph
local castToGraph = require(Package.Graph.castToGraph)
local depend = require(Package.Graph.depend)
-- Utility
local nameOf = require(Package.Utility.nameOf)

type Self = Types.Observer & {
	_watchingGraph: Types.GraphObject?,
	_changeListeners: {[unknown]: () -> ()}
}

local class = {}
class.type = "Observer"
class.timeliness = "eager"

local METATABLE = {__index = class}

local function Observer(
	scope: Types.Scope<unknown>,
	watching: unknown
): Self
	if watching == nil then
		External.logError("scopeMissing", nil, "Observers", "myScope:Observer(watching)")
	end
	local watchingGraph = castToGraph(watching)
	if watchingGraph ~= nil and watchingGraph.scope == nil then
		External.logError(
			"useAfterDestroy",
			nil,
			`The {nameOf(watchingGraph, "watched")} object`,
			`the Observer that is watching it`
		)
	end
	
	local self: Self = setmetatable(
		{
			scope = scope,
			dependencySet = {},
			dependentSet = {},
			lastChange = nil,
			validity = "valid",
			_watchingGraph = watching,
			_changeListeners = {}
		},
		METATABLE
	) :: any
	local destroy = function()
		self.scope = nil
		for dependency in pairs(self.dependencySet) do
			dependency.dependentSet[self] = nil
		end
	end
	self.oldestTask = destroy
	table.insert(scope, destroy)

	if watchingGraph ~= nil then
		if whichLivesLonger(scope, self, watchingGraph.scope :: any, watching) == "definitely-a" then
			External.logWarn(
				"possiblyOutlives",
				`The {nameOf(watchingGraph, "watched")} object`,
				`the Observer that is watching it`
			)
		end
		depend(self, watchingGraph)
	end
	return self
end

function class.onBind(
	self: Self,
	callback: () -> ()
): () -> ()
	External.doTaskImmediate(callback)
	return self:onChange(callback)
end

function class.onChange(
	self: Self,
	callback: () -> ()
): () -> ()
	local uniqueIdentifier = {}
	self._changeListeners[uniqueIdentifier] = callback
	return function()
		self._changeListeners[uniqueIdentifier] = nil
	end
end

function class._evaluate(
	self: Self
): ()
	if self._watchingGraph ~= nil then
		depend(self, self._watchingGraph)
	end
	for _, callback in pairs(self._changeListeners) do
		External.doTaskImmediate(callback)
	end
	return false
end

return Observer