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
			local target = graph.objects[graph.shape.objects[1]]
			tryInvalidate(target)
			if target.validity ~= "valid" then
				return `Validity was "{target.validity}" instead of "valid"`
			end
			return true
		end
	} (describe)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "always updates the last changed time of the target",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			local target = graph.objects[graph.shape.objects[1]]
			local before = target.lastChange
			tryInvalidate(target)
			if target.lastChange == before then
				return "The last change time stayed identical"
			else
				return true
			end
		end
	} (describe)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "invalidates valid direct dependents",
		filters = {Graphs.filters.wellFormed, Graphs.filters.dependentDepthOf(1)},
		perform = function(
			graph: Graphs.Graph
		)
			local target = graph.objects[graph.shape.objects[1]]
			tryInvalidate(target)
			for dependent in target.dependentSet do
				if dependent.validity ~= "invalid" then
					local name = (dependent :: any).name or "GraphObject"
					return `Dependent {name} was "{dependent.validity}" instead of "invalid"`
				end
			end
			return true
		end
	} (describe)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "stops at already-invalid direct dependents",
		filters = {Graphs.filters.wellFormed, Graphs.filters.dependentDepthOf(2)},
		prepare = function(
			shape: Graphs.GraphShape
		)
			local target = shape.objects[1]
			local objects: {[string]: Graphs.ObjectTemplate} = {}
			for _, edge in shape.edges do
				if edge.from == target then
					local dependent = edge.to
					objects[dependent] = {
						validity = "invalid"
					}
				end
			end
			return {
				Graphs.make({}, {
					shape = shape,
					objects = objects
				})
			}
		end,
		perform = function(
			graph: Graphs.Graph
		)
			local target = graph.objects[graph.shape.objects[1]]
			tryInvalidate(target)
			for dependent in target.dependentSet do
				for subDependent in dependent.dependentSet do
					if subDependent.validity ~= "valid" then
						local name = (subDependent :: any).name or "GraphObject"
						return `Sub-dependent {name} was "{dependent.validity}" instead of "valid"`
					end
				end
			end
			return true
		end
	} (describe)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "invalidates valid transitive dependents",
		filters = {Graphs.filters.wellFormed, Graphs.filters.dependentDepthOf(2)},
		perform = function(
			graph: Graphs.Graph
		)
			local target = graph.objects[graph.shape.objects[1]]
			tryInvalidate(target)
			for dependent in target.dependentSet do
				for subDependent in dependent.dependentSet do
					if subDependent.validity ~= "invalid" then
						local name = (subDependent :: any).name or "GraphObject"
						return `Sub-dependent {name} was "{dependent.validity}" instead of "invalid"`
					end
				end
			end
			return true
		end
	} (describe)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "stops at already-invalid transitive dependents",
		filters = {Graphs.filters.wellFormed, Graphs.filters.dependentDepthOf(3)},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "does *not* invalidate any dependencies, direct or transitive",
		filters = {Graphs.filters.wellFormed, Graphs.filters.dependencyDepthOf(1)},
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
				return true
			end
		end
	} (describe)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "throws when encountering a busy object",
		filters = {Graphs.filters.wellFormed, Graphs.filters.dependentDepthOf(1)},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "revalidates eager graph objects after all invalidation completes",
		filters = {Graphs.filters.wellFormed, Graphs.filters.dependentDepthOf(1)},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)
end