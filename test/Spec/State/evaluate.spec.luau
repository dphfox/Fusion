--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local evaluate = require(Fusion.State.evaluate)

local Graphs = require(script.Parent.Parent.Parent.Util.Graphs)

return function()
	local describe = getfenv().describe

	Graphs.propertyTest {
		testing = "evaluate",
		it = "always ensures the target is valid",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "always ensures the last change time is non-nil, even after meaningless changes",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "does *not* evaluate prior dependencies",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "allows evaluating/depending on objects during revalidation",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "does *not* preserve dependency connections",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "preserves dependent connections",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "does *not* evaluate dependents",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "does *not* run computations for already-valid objects",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "runs computations for invalid objects",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "updates the last change time for meaningful changes in direct dependencies",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "updates the last change time for meaningful changes in transitive dependencies",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)
		
	Graphs.propertyTest {
		testing = "evaluate",
		it = "does *not* update the last change time for meaningless changes in direct dependencies",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "does *not* update the last change time for meaningless changes in transitive dependencies",
		filters = {Graphs.filters.wellFormed},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "throws an error for malformed graphs in finite time",
		filters = {Graphs.filters.malformed},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)

	Graphs.propertyTest {
		testing = "evaluate",
		it = "throws when encountering a busy object",
		filters = {Graphs.filters.wellFormed},
		preparation = {
			count = 1,
			prepare = function(
				graph: Graphs.Graph
			)
				for _, object in graph.allObjects do
					object.validity = "busy"
				end
			end
		},
		perform = function(
			graph: Graphs.Graph
		)
			return "not implemented"
		end
	} (describe)
end