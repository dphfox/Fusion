--[[
	Represents the state relevant while executing a test plan.

	Used by TestRunner to produce a TestResults object.

	Uses the same tree building structure as TestPlanBuilder; TestSession keeps
	track of a stack of nodes that represent the current path through the tree.
]]

local TestEnum = require(script.Parent.TestEnum)
local TestResults = require(script.Parent.TestResults)
local Context = require(script.Parent.Context)
local ExpectationContext = require(script.Parent.ExpectationContext)

local TestSession = {}

TestSession.__index = TestSession

--[[
	Create a TestSession related to the given TestPlan.

	The resulting TestResults object will be linked to this TestPlan.
]]
function TestSession.new(plan)
	local self = {
		results = TestResults.new(plan),
		nodeStack = {},
		contextStack = {},
		expectationContextStack = {},
		hasFocusNodes = false
	}

	setmetatable(self, TestSession)

	return self
end

--[[
	Calculate success, failure, and skipped test counts in the tree at the
	current point in the execution.
]]
function TestSession:calculateTotals()
	local results = self.results

	results.successCount = 0
	results.failureCount = 0
	results.skippedCount = 0

	results:visitAllNodes(function(node)
		local status = node.status
		local nodeType = node.planNode.type

		if nodeType == TestEnum.NodeType.It then
			if status == TestEnum.TestStatus.Success then
				results.successCount = results.successCount + 1
			elseif status == TestEnum.TestStatus.Failure then
				results.failureCount = results.failureCount + 1
			elseif status == TestEnum.TestStatus.Skipped then
				results.skippedCount = results.skippedCount + 1
			end
		end
	end)
end

--[[
	Gathers all of the errors reported by tests and puts them at the top level
	of the TestResults object.
]]
function TestSession:gatherErrors()
	local results = self.results

	results.errors = {}

	results:visitAllNodes(function(node)
		if #node.errors > 0 then
			for _, message in ipairs(node.errors) do
				table.insert(results.errors, message)
			end
		end
	end)
end

--[[
	Calculates test totals, verifies the tree is valid, and returns results.
]]
function TestSession:finalize()
	if #self.nodeStack ~= 0 then
		error("Cannot finalize TestResults with nodes still on the stack!", 2)
	end

	self:calculateTotals()
	self:gatherErrors()

	return self.results
end

--[[
	Create a new test result node and push it onto the navigation stack.
]]
function TestSession:pushNode(planNode)
	local node = TestResults.createNode(planNode)
	local lastNode = self.nodeStack[#self.nodeStack] or self.results
	table.insert(lastNode.children, node)
	table.insert(self.nodeStack, node)

	local lastContext = self.contextStack[#self.contextStack]
	local context = Context.new(lastContext)
	table.insert(self.contextStack, context)

	local lastExpectationContext = self.expectationContextStack[#self.expectationContextStack]
	local expectationContext = ExpectationContext.new(lastExpectationContext)
	table.insert(self.expectationContextStack, expectationContext)
end

--[[
	Pops a node off of the navigation stack.
]]
function TestSession:popNode()
	assert(#self.nodeStack > 0, "Tried to pop from an empty node stack!")
	table.remove(self.nodeStack, #self.nodeStack)
	table.remove(self.contextStack, #self.contextStack)
	table.remove(self.expectationContextStack, #self.expectationContextStack)
end

--[[
	Gets the Context object for the current node.
]]
function TestSession:getContext()
	assert(#self.contextStack > 0, "Tried to get context from an empty stack!")
	return self.contextStack[#self.contextStack]
end


function TestSession:getExpectationContext()
	assert(#self.expectationContextStack > 0, "Tried to get expectationContext from an empty stack!")
	return self.expectationContextStack[#self.expectationContextStack]
end

--[[
	Tells whether the current test we're in should be skipped.
]]
function TestSession:shouldSkip()
	-- If our test tree had any exclusive tests, then normal tests are skipped!
	if self.hasFocusNodes then
		for i = #self.nodeStack, 1, -1 do
			local node = self.nodeStack[i]

			-- Skipped tests are still skipped
			if node.planNode.modifier == TestEnum.NodeModifier.Skip then
				return true
			end

			-- Focused tests are the only ones that aren't skipped
			if node.planNode.modifier == TestEnum.NodeModifier.Focus then
				return false
			end
		end

		return true
	else
		for i = #self.nodeStack, 1, -1 do
			local node = self.nodeStack[i]

			if node.planNode.modifier == TestEnum.NodeModifier.Skip then
				return true
			end
		end
	end

	return false
end

--[[
	Set the current node's status to Success.
]]
function TestSession:setSuccess()
	assert(#self.nodeStack > 0, "Attempting to set success status on empty stack")
	self.nodeStack[#self.nodeStack].status = TestEnum.TestStatus.Success
end

--[[
	Set the current node's status to Skipped.
]]
function TestSession:setSkipped()
	assert(#self.nodeStack > 0, "Attempting to set skipped status on empty stack")
	self.nodeStack[#self.nodeStack].status = TestEnum.TestStatus.Skipped
end

--[[
	Set the current node's status to Failure and adds a message to its list of
	errors.
]]
function TestSession:setError(message)
	assert(#self.nodeStack > 0, "Attempting to set error status on empty stack")
	local last = self.nodeStack[#self.nodeStack]
	last.status = TestEnum.TestStatus.Failure
	table.insert(last.errors, message)
end

--[[
	Add a dummy child node to the current node to hold the given error. This
	allows an otherwise empty describe node to report an error in a more natural
	way.
]]
function TestSession:addDummyError(phrase, message)
	self:pushNode({type = TestEnum.NodeType.It, phrase = phrase})
	self:setError(message)
	self:popNode()
	self.nodeStack[#self.nodeStack].status = TestEnum.TestStatus.Failure
end

--[[
	Set the current node's status based on that of its children. If all children
	are skipped, mark it as skipped. If any are fails, mark it as failed.
	Otherwise, mark it as success.
]]
function TestSession:setStatusFromChildren()
	assert(#self.nodeStack > 0, "Attempting to set status from children on empty stack")

	local last = self.nodeStack[#self.nodeStack]
	local status = TestEnum.TestStatus.Success
	local skipped = true

	-- If all children were skipped, then we were skipped
	-- If any child failed, then we failed!
	for _, child in ipairs(last.children) do
		if child.status ~= TestEnum.TestStatus.Skipped then
			skipped = false

			if child.status == TestEnum.TestStatus.Failure then
				status = TestEnum.TestStatus.Failure
			end
		end
	end

	if skipped then
		status = TestEnum.TestStatus.Skipped
	end

	last.status = status
end

return TestSession
