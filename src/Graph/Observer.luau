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
local checkLifetime = require(Package.Memory.checkLifetime)
-- Graph
local castToGraph = require(Package.Graph.castToGraph)
local depend = require(Package.Graph.depend)
local evaluate = require(Package.Graph.evaluate)
-- Utility
local nicknames = require(Package.Utility.nicknames)

type Self = Types.Observer & {
	_watchingGraph: Types.GraphObject?,
	_changeListeners: {[unknown]: () -> ()}
}

local class = {}
class.type = "Observer"
class.timeliness = "eager"
class.dependentSet = table.freeze {}

local METATABLE = table.freeze {__index = class}

local function Observer(
	scope: Types.Scope<unknown>,
	watching: unknown
): Types.Observer
	local createdAt = os.clock()
	if watching == nil then
		External.logError("scopeMissing", nil, "Observers", "myScope:Observer(watching)")
	end

	local self: Self = setmetatable(
		{
			scope = scope,
			createdAt = createdAt,
			dependencySet = {},
			lastChange = nil,
			validity = "invalid",
			_watchingGraph = castToGraph(watching),
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
	nicknames[self.oldestTask] = "Observer"
	table.insert(scope, destroy)

	if self._watchingGraph ~= nil then
		checkLifetime.bOutlivesA(
			scope, self.oldestTask,
			self._watchingGraph.scope, self._watchingGraph.oldestTask,
			checkLifetime.formatters.observer
		)
	end

	-- Eagerly evaluated objects need to evaluate themselves so that they're
	-- valid at all times.
	evaluate(self, true)

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
	local uniqueIdentifier = table.freeze {}
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
	for _, callback in self._changeListeners do
		External.doTaskImmediate(callback)
	end
	return true
end

table.freeze(class)
return Observer :: Types.ObserverConstructor