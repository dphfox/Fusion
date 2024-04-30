--[[
	Copy of TextReporter that doesn't output successful tests.

	This should be temporary, it's just a workaround to make CI environments
	happy in the short-term.
]]

local TestService = game:GetService("TestService")

local TestEnum = require(script.Parent.Parent.TestEnum)

local INDENT = (" "):rep(3)
local STATUS_SYMBOLS = {
	[TestEnum.TestStatus.Success] = "+",
	[TestEnum.TestStatus.Failure] = "-",
	[TestEnum.TestStatus.Skipped] = "~"
}
local UNKNOWN_STATUS_SYMBOL = "?"

local TextReporterQuiet = {}

local function reportNode(node, buffer, level)
	buffer = buffer or {}
	level = level or 0

	if node.status == TestEnum.TestStatus.Skipped then
		return buffer
	end

	local line

	if node.status ~= TestEnum.TestStatus.Success then
		local symbol = STATUS_SYMBOLS[node.status] or UNKNOWN_STATUS_SYMBOL

		line = ("%s[%s] %s"):format(
			INDENT:rep(level),
			symbol,
			node.planNode.phrase
		)
	end

	table.insert(buffer, line)

	for _, child in ipairs(node.children) do
		reportNode(child, buffer, level + 1)
	end

	return buffer
end

local function reportRoot(node)
	local buffer = {}

	for _, child in ipairs(node.children) do
		reportNode(child, buffer, 0)
	end

	return buffer
end

local function report(root)
	local buffer = reportRoot(root)

	return table.concat(buffer, "\n")
end

function TextReporterQuiet.report(results)
	local resultBuffer = {
		"Test results:",
		report(results),
		("%d passed, %d failed, %d skipped"):format(
			results.successCount,
			results.failureCount,
			results.skippedCount
		)
	}

	print(table.concat(resultBuffer, "\n"))

	if results.failureCount > 0 then
		print(("%d test nodes reported failures."):format(results.failureCount))
	end

	if #results.errors > 0 then
		print("Errors reported by tests:")
		print("")

		for _, message in ipairs(results.errors) do
			TestService:Error(message)

			-- Insert a blank line after each error
			print("")
		end
	end
end

return TextReporterQuiet