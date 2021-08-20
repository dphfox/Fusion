--[[
	Turns a series of specification functions into a test plan.

	Uses a TestPlanBuilder to keep track of the state of the tree being built.
]]
local TestPlan = require(script.Parent.TestPlan)

local TestPlanner = {}

--[[
	Create a new TestPlan from a list of specification functions.

	These functions should call a combination of `describe` and `it` (and their
	variants), which will be turned into a test plan to be executed.

	Parameters:
		- modulesList - list of tables describing test modules {
			method, -- specification function described above
			path, -- array of parent entires, first element is the leaf that owns `method`
			pathStringForSorting -- a string representation of `path`, used for sorting of the test plan
		}
		- testNamePattern - Only tests matching this Lua pattern string will run. Pass empty or nil to run all tests
		- extraEnvironment - Lua table holding additional functions and variables to be injected into the specification
							function during execution
]]
function TestPlanner.createPlan(modulesList, testNamePattern, extraEnvironment)
	local plan = TestPlan.new(testNamePattern, extraEnvironment)

	table.sort(modulesList, function(a, b)
		return a.pathStringForSorting < b.pathStringForSorting
	end)

	for _, module in ipairs(modulesList) do
		plan:addRoot(module.path, module.method)
	end

	return plan
end

return TestPlanner