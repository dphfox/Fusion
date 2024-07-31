--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local Types = require(Fusion.Types)
local change = require(Fusion.Graph.change)

local Graphs = require(script.Parent.Parent.Parent.Util.Graphs)

return function()
	local describe = getfenv().describe

	Graphs.propertyTest {
		testing = "change",
		it = "always ensures the target is valid",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			for _, target in graph.allObjects do
				change(target)
			end
			return Graphs.check(
				graph.allObjects,
				Graphs.tests.validity("valid")
			)
		end
	} (describe)

	Graphs.propertyTest {
		testing = "change",
		it = "always changes the last changed time of the target",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			for _, object in graph.allObjects do
				local before = object.lastChange
				change(object)
				if object.lastChange == before then
					return `{Graphs.nameOf(object)} didn't change its last change time`
				end
			end
			return false
		end
	} (describe)

	Graphs.propertyTest {
		testing = "change",
		it = "invalidates valid direct dependents",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			local targets = Graphs.selectors.noConnections(graph.allObjects, "dependency")
			for _, target in targets do
				change(target)
			end
			return Graphs.check(
				Graphs.selectors.distance(graph.allObjects, targets, "dependent", 1),
				Graphs.tests.validity("invalid")
			)
		end
	} (describe)

	Graphs.propertyTest {
		testing = "change",
		it = "stops at already-invalid direct dependents",
		filters = {Graphs.filters.wellFormed},
		preparation = {
			count = 1,
			prepare = function(
				graph: Graphs.Graph
			)
				local targets = Graphs.selectors.noConnections(graph.allObjects, "dependency")
				for _, object in 
					Graphs.selectors.distance(graph.allObjects, targets, "dependent", 1) 
				do
					object.validity = "invalid"
				end
				return {graph}
			end
		},
		perform = function(
			graph: Graphs.Graph
		)
			local targets = Graphs.selectors.noConnections(graph.allObjects, "dependency")
			for _, target in targets do
				change(target)
			end
			return Graphs.check(
				Graphs.selectors.distance(graph.allObjects, targets, "dependent", 2),
				Graphs.tests.validity("valid")
			)
		end
	} (describe)

	Graphs.propertyTest {
		testing = "change",
		it = "invalidates valid transitive dependents",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			local targets = Graphs.selectors.noConnections(graph.allObjects, "dependency")
			for _, target in targets do
				change(target)
			end
			return Graphs.check(
				Graphs.selectors.distance(graph.allObjects, targets, "dependent", 2),
				Graphs.tests.validity("invalid")
			)
		end
	} (describe)

	Graphs.propertyTest {
		testing = "change",
		it = "stops at already-invalid transitive dependents",
		filters = {Graphs.filters.wellFormed},
		preparation = {
			count = 1,
			prepare = function(
				graph: Graphs.Graph
			)
				local targets = Graphs.selectors.noConnections(graph.allObjects, "dependency")
				for _, object in 
					Graphs.selectors.distance(graph.allObjects, targets, "dependent", 2)
				do
					object.validity = "invalid"
				end
				return {graph}
			end
		},
		perform = function(
			graph: Graphs.Graph
		)
			local targets = Graphs.selectors.noConnections(graph.allObjects, "dependency")
			for _, target in targets do
				change(target)
			end
			return Graphs.check(
				Graphs.selectors.distance(graph.allObjects, targets, "dependent", 3),
				Graphs.tests.validity("valid")
			)
		end
	} (describe)

	Graphs.propertyTest {
		testing = "change",
		it = "does *not* invalidate any dependencies, direct or transitive",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			local targets = Graphs.selectors.noConnections(graph.allObjects, "dependent")
			for _, target in targets do
				change(target)
			end
			return Graphs.check(
				Graphs.selectors.distance(graph.allObjects, targets, "dependency", 1),
				Graphs.tests.validity("valid")
			) or Graphs.check(
				Graphs.selectors.distance(graph.allObjects, targets, "dependency", 2),
				Graphs.tests.validity("valid")
			)
		end
	} (describe)

	Graphs.propertyTest {
		testing = "change",
		it = "processes malformed graphs in finite time",
		filters = {Graphs.filters.malformed},
		perform = function(
			graph: Graphs.Graph
		)
			local ok, err = pcall(function()
				for _, object in graph.objects do
					change(object)
					for _, object in graph.objects do
						object.validity = "valid"
					end
				end
			end)
			if ok or string.find(err, "infiniteLoop", 1, true) ~= nil then
				return false
			else
				return err
			end
		end
	} (describe)

	Graphs.propertyTest {
		testing = "change",
		it = "throws when encountering a busy object",
		filters = {Graphs.filters.wellFormed},
		preparation = {
			count = 1,
			prepare = function(
				graph: Graphs.Graph
			)
				local objects = Graphs.selectors.noConnections(graph.allObjects, "dependent")
				for _, object in objects do
					object.validity = "busy"
				end
			end
		},
		perform = function(
			graph: Graphs.Graph
		)
			local ok, err = pcall(function()
				for _, object in graph.objects do
					change(object)
				end
			end)
			if ok then
				return "Should not have completed without errors"
			elseif string.find(err, "infiniteLoop", 1, true) ~= nil then
				return false
			else
				return err
			end
		end
	} (describe)

	Graphs.propertyTest {
		testing = "change",
		it = "revalidates eager objects after all invalidation is complete",
		filters = {Graphs.filters.wellFormed},
		preparation = {
			count = 1,
			prepare = function(
				graph: Graphs.Graph
			)
				local objects = Graphs.selectors.noConnections(graph.allObjects, "dependent")
				local doNotInvalidate: {Types.GraphObject}
				for _, object in objects do
					object.timeliness = "eager"
					object._evaluate = function(self)
						if doNotInvalidate == nil then
							doNotInvalidate = {}
							for _, object in graph.objects do
								if object.validity ~= "invalid" then
									table.insert(doNotInvalidate, object)
								end
							end
						else
							for _, object in doNotInvalidate do
								if object.validity == "invalid" then
									error(`{Graphs.nameOf(object)} became invalid between revalidations`, 0)
								end
							end
						end
						return true
					end
				end
			end
		},
		perform = function(
			graph: Graphs.Graph
		)
			local targets = Graphs.selectors.noConnections(graph.allObjects, "dependency")
			local eagers = Graphs.selectors.noConnections(graph.allObjects, "dependent")
			for _, target in targets do
				change(target)
			end
			return Graphs.check(
				eagers,
				Graphs.tests.validity("valid")
			)
		end
	} (describe)

	Graphs.propertyTest {
		testing = "change",
		it = "revalidates eager objects in order of creation",
		filters = {Graphs.filters.wellFormed},
		preparation = {
			count = 1,
			prepare = function(
				graph: Graphs.Graph
			)
				local graph: Graphs.Graph & {
					properOrder: {Types.GraphObject},
					executionOrder: {Types.GraphObject}
				} = graph :: any
				graph.properOrder = {}
				graph.executionOrder = {}
				local objects = Graphs.selectors.noConnections(graph.allObjects, "dependent")
				local doNotInvalidate: {Types.GraphObject}
				local createAtTime = 0
				for _, object in objects do
					object.timeliness = "eager"
					createAtTime += 1
					object.createdAt = createAtTime
					table.insert(graph.properOrder, object)
					object._evaluate = function(self)
						table.insert(graph.executionOrder, object)
						return true
					end
				end
			end
		},
		perform = function(
			graph: Graphs.Graph
		)
			local graph: Graphs.Graph & {
				properOrder: {Types.GraphObject},
				executionOrder: {Types.GraphObject}
			} = graph :: any

			local targets = Graphs.selectors.noConnections(graph.allObjects, "dependency")
			local eagers = Graphs.selectors.noConnections(graph.allObjects, "dependent")
			for _, target in targets do
				change(target)
			end

			for index, properObject in graph.properOrder do
				if properObject ~= graph.executionOrder[index] then
					return `Object {index} was evaluated out of order.`
				end
			end

			return false
		end
	} (describe)
end