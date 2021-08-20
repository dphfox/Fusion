--[[
	Represents a tree of test results.

	Each node in the tree corresponds directly to a node in a corresponding
	TestPlan, accessible via the 'planNode' field.

	TestResults objects are produced by TestRunner using TestSession as state.
]]

local TestEnum = require(script.Parent.TestEnum)

local STATUS_SYMBOLS = {
	[TestEnum.TestStatus.Success] = "+",
	[TestEnum.TestStatus.Failure] = "-",
	[TestEnum.TestStatus.Skipped] = "~"
}

local TestResults = {}

TestResults.__index = TestResults

--[[
	Create a new TestResults tree that's linked to the given TestPlan.
]]
function TestResults.new(plan)
	local self = {
		successCount = 0,
		failureCount = 0,
		skippedCount = 0,
		planNode = plan,
		children = {},
		errors = {}
	}

	setmetatable(self, TestResults)

	return self
end

--[[
	Create a new result node that can be inserted into a TestResult tree.
]]
function TestResults.createNode(planNode)
	local node = {
		planNode = planNode,
		children = {},
		errors = {},
		status = nil
	}

	return node
end

--[[
	Visit all test result nodes, depth-first.
]]
function TestResults:visitAllNodes(callback, root)
	root = root or self

	for _, child in ipairs(root.children) do
		callback(child)

		self:visitAllNodes(callback, child)
	end
end

--[[
	Creates a debug visualization of the test results.
]]
function TestResults:visualize(root, level)
	root = root or self
	level = level or 0

	local buffer = {}

	for _, child in ipairs(root.children) do
		if child.planNode.type == TestEnum.NodeType.It then
			local symbol = STATUS_SYMBOLS[child.status] or "?"
			local str = ("%s[%s] %s"):format(
				(" "):rep(3 * level),
				symbol,
				child.planNode.phrase
			)

			if child.messages and #child.messages > 0 then
				str = str .. "\n " .. (" "):rep(3 * level) .. table.concat(child.messages, "\n " .. (" "):rep(3 * level))
			end

			table.insert(buffer, str)
		else
			local str = ("%s%s"):format(
				(" "):rep(3 * level),
				child.planNode.phrase or ""
			)

			if child.status then
				str = str .. (" (%s)"):format(child.status)
			end

			table.insert(buffer, str)

			if #child.children > 0 then
				local text = self:visualize(child, level + 1)
				table.insert(buffer, text)
			end
		end
	end

	return table.concat(buffer, "\n")
end

return TestResults