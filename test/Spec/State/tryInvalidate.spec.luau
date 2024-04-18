--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local tryInvalidate = require(Fusion.State.tryInvalidate)

local Graphs = require(script.Parent.Parent.Parent.Util.Graphs)
local FiniteTime = require(script.Parent.Parent.Parent.Util.FiniteTime)

return function()
	local it = getfenv().itFOCUS

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "always ensures the target is valid",
		init = function(
			shape: Graphs.GraphShape
		)
			return not shape.facts.cyclic
		end,
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
	} (it)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "always updates the last changed time of the target",
		init = function(
			shape: Graphs.GraphShape
		)
			return not shape.facts.cyclic
		end,
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
	} (it)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "invalidates valid direct dependents",
		init = function(
			shape: Graphs.GraphShape
		)
			if shape.facts.cyclic then
				return false
			end
			local target = shape.objects[1]
			for _, edge in shape.edges do
				if edge.from == target then
					return true
				end
			end
			return false
		end,
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
	} (it)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "stops at already-invalid direct dependents",
		init = function(
			shape: Graphs.GraphShape
		)
			return {}
		end,
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (it)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "invalidates valid transitive dependents",
		init = function(
			shape: Graphs.GraphShape
		)
			return {}
		end,
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (it)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "stops at already-invalid transitive dependents",
		init = function(
			shape: Graphs.GraphShape
		)
			return {}
		end,
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (it)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "does *not* invalidate any dependencies, direct or transitive",
		init = function(
			shape: Graphs.GraphShape
		)
			return {}
		end,
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (it)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "throws an error for cyclic graphs in finite time",
		init = function(
			shape: Graphs.GraphShape
		)
			return shape.facts.cyclic
		end,
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
	} (it)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "throws when encountering a busy object",
		init = function(
			shape: Graphs.GraphShape
		)
			return {}
		end,
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (it)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "revalidates eager graph objects after all invalidation completes",
		init = function(
			shape: Graphs.GraphShape
		)
			return {}
		end,
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (it)
end