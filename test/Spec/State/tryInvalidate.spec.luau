--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local tryInvalidate = require(Fusion.State.tryInvalidate)

local Graphs = require(script.Parent.Parent.Parent.Util.Graphs)
local FiniteTime = require(script.Parent.Parent.Parent.Util.FiniteTime)

return function()
	local describe = getfenv().describe

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "always ensures the target is valid",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			local targets = Graphs.selectors.dependencyDepthOf(graph, 0)
			for _, target in targets do
				tryInvalidate(target)
			end
			return Graphs.check(
				targets,
				Graphs.tests.validity("valid")
			)
		end
	} (describe)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "always updates the last changed time of the target",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			for _, target in Graphs.selectors.dependencyDepthOf(graph, 0) do
				local before = target.lastChange
				tryInvalidate(target)
				if target.lastChange == before then
					return `{Graphs.nameOf(target)} didn't change its last change time`
				end
			end
			return false
		end
	} (describe)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "invalidates valid direct dependents",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			local targets = Graphs.selectors.dependencyDepthOf(graph, 0)
			for _, target in targets do
				tryInvalidate(target)
			end
			return Graphs.check(
				Graphs.selectors.objectDependents(targets),
				Graphs.tests.validity("invalid")
			)
		end
	} (describe)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "stops at already-invalid direct dependents",
		filters = {Graphs.filters.wellFormed},
		prepare = function(
			graph: Graphs.Graph
		)
			for _, object in 
				Graphs.selectors.objectDependents(
					Graphs.selectors.dependencyDepthOf(graph, 0)
				) 
			do
				object.validity = "invalid"
			end
			return {graph}
		end,
		perform = function(
			graph: Graphs.Graph
		)
			local targets = Graphs.selectors.dependencyDepthOf(graph, 0)
			for _, target in targets do
				tryInvalidate(target)
			end
			return Graphs.check(
				Graphs.selectors.objectDependencies(
					Graphs.selectors.objectDependencies(targets)
				),
				Graphs.tests.validity("valid")
			)
		end
	} (describe)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "invalidates valid transitive dependents",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			local targets = Graphs.selectors.dependencyDepthOf(graph, 0)
			for _, target in targets do
				tryInvalidate(target)
			end
			return Graphs.check(
				Graphs.selectors.objectDependents(
					Graphs.selectors.objectDependents(targets)
				),
				Graphs.tests.validity("invalid")
			)
		end
	} (describe)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "stops at already-invalid transitive dependents",
		filters = {Graphs.filters.wellFormed},
		prepare = function(
			graph: Graphs.Graph
		)
			for _, object in 
				Graphs.selectors.objectDependents(
					Graphs.selectors.objectDependents(
						Graphs.selectors.dependencyDepthOf(graph, 0)
					) 
				) 
			do
				object.validity = "invalid"
			end
			return {graph}
		end,
		perform = function(
			graph: Graphs.Graph
		)
			local targets = Graphs.selectors.dependencyDepthOf(graph, 0)
			for _, target in targets do
				tryInvalidate(target)
			end
			return Graphs.check(
				Graphs.selectors.objectDependents(
					Graphs.selectors.objectDependents(
						Graphs.selectors.objectDependents(targets)
					)
				),
				Graphs.tests.validity("invalid")
			)
		end
	} (describe)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "does *not* invalidate any dependencies, direct or transitive",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "throws an error for malformed graphs in finite time",
		filters = {Graphs.filters.malformed},
		perform = function(
			graph: Graphs.Graph
		)
			local target = graph.objects[graph.shape.objects[1]]
			local timeCheck = FiniteTime.start()

			for _, object in graph.objects do
				local metatable = getmetatable(object :: any)
				if metatable == nil then
					metatable = {}
					setmetatable(object, metatable)
				end
				local realValidity = object.validity
				object.validity = nil :: any
				function metatable:__index(key)
					if key == "validity" then
						timeCheck()
						return realValidity
					else
						return rawget(self, key)
					end
				end
				function metatable:__newindex(key, value)
					if key == "validity" then
						timeCheck()
						realValidity = value
					else
						return rawset(self, key, value)
					end
				end
			end

			local ok, err = pcall(tryInvalidate :: any, target)

			if ok then
				return "Should not have completed without errors"
			elseif string.find(err, "infiniteLoop", 1, true) == nil then
				return err
			else
				return false
			end
		end
	} (describe)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "throws when encountering a busy object",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "revalidates eager graph objects after all invalidation completes",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)
end