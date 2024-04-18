--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local tryInvalidate = require(Fusion.State.tryInvalidate)

local Graphs = require(script.Parent.Parent.Parent.Util.Graphs)

return function()
	local it = getfenv().itFOCUS

	it("# focuses on this", function() end)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "always ensures the target is valid",
		init = function(
			shape: Graphs.GraphShape
		): {
			{
				subName: string,
				graph: Graphs.Graph
			}
		}
			return {}
		end,
		perform = function(
			graph: Graphs.Graph
		): string | true
			return "not implemented"
		end
	} (it)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "always updates the last changed time of the target",
		init = function(
			shape: Graphs.GraphShape
		): {
			{
				subName: string,
				graph: Graphs.Graph
			}
		}
			return {}
		end,
		perform = function(
			graph: Graphs.Graph
		): string | true
			return "not implemented"
		end
	} (it)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "invalidates valid direct dependents",
		init = function(
			shape: Graphs.GraphShape
		): {
			{
				subName: string,
				graph: Graphs.Graph
			}
		}
			return {}
		end,
		perform = function(
			graph: Graphs.Graph
		): string | true
			return "not implemented"
		end
	} (it)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "stops at already-invalid direct dependents",
		init = function(
			shape: Graphs.GraphShape
		): {
			{
				subName: string,
				graph: Graphs.Graph
			}
		}
			return {}
		end,
		perform = function(
			graph: Graphs.Graph
		): string | true
			return "not implemented"
		end
	} (it)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "invalidates valid transitive dependents",
		init = function(
			shape: Graphs.GraphShape
		): {
			{
				subName: string,
				graph: Graphs.Graph
			}
		}
			return {}
		end,
		perform = function(
			graph: Graphs.Graph
		): string | true
			return "not implemented"
		end
	} (it)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "stops at already-invalid transitive dependents",
		init = function(
			shape: Graphs.GraphShape
		): {
			{
				subName: string,
				graph: Graphs.Graph
			}
		}
			return {}
		end,
		perform = function(
			graph: Graphs.Graph
		): string | true
			return "not implemented"
		end
	} (it)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "does *not* invalidate any dependencies, direct or transitive",
		init = function(
			shape: Graphs.GraphShape
		): {
			{
				subName: string,
				graph: Graphs.Graph
			}
		}
			return {}
		end,
		perform = function(
			graph: Graphs.Graph
		): string | true
			return "not implemented"
		end
	} (it)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "succeeds in finite time for cyclic graphs",
		init = function(
			shape: Graphs.GraphShape
		): {
			{
				subName: string,
				graph: Graphs.Graph
			}
		}
			return {}
		end,
		perform = function(
			graph: Graphs.Graph
		): string | true
			return "not implemented"
		end
	} (it)

	Graphs.propertyTest {
		testing = "tryInvalidate",
		it = "throws when encountering a busy object",
		init = function(
			shape: Graphs.GraphShape
		): {
			{
				subName: string,
				graph: Graphs.Graph
			}
		}
			return {}
		end,
		perform = function(
			graph: Graphs.Graph
		): string | true
			return "not implemented"
		end
	} (it)
end