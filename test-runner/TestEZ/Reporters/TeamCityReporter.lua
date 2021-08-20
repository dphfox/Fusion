local TestService = game:GetService("TestService")

local TestEnum = require(script.Parent.Parent.TestEnum)

local TeamCityReporter = {}

local function teamCityEscape(str)
	str = string.gsub(str, "([]|'[])","|%1")
	str = string.gsub(str, "\r", "|r")
	str = string.gsub(str, "\n", "|n")
	return str
end

local function teamCityEnterSuite(suiteName)
	return string.format("##teamcity[testSuiteStarted name='%s']", teamCityEscape(suiteName))
end

local function teamCityLeaveSuite(suiteName)
	return string.format("##teamcity[testSuiteFinished name='%s']", teamCityEscape(suiteName))
end

local function teamCityEnterCase(caseName)
	return string.format("##teamcity[testStarted name='%s']", teamCityEscape(caseName))
end

local function teamCityLeaveCase(caseName)
	return string.format("##teamcity[testFinished name='%s']", teamCityEscape(caseName))
end

local function teamCityFailCase(caseName, errorMessage)
	return string.format("##teamcity[testFailed name='%s' message='%s']",
		teamCityEscape(caseName), teamCityEscape(errorMessage))
end

local function reportNode(node, buffer, level)
	buffer = buffer or {}
	level = level or 0
	if node.status == TestEnum.TestStatus.Skipped then
		return buffer
	end
	if node.planNode.type == TestEnum.NodeType.Describe then
		table.insert(buffer, teamCityEnterSuite(node.planNode.phrase))
		for _, child in ipairs(node.children) do
			reportNode(child, buffer, level + 1)
		end
		table.insert(buffer, teamCityLeaveSuite(node.planNode.phrase))
	else
		table.insert(buffer, teamCityEnterCase(node.planNode.phrase))
		if node.status == TestEnum.TestStatus.Failure then
			table.insert(buffer, teamCityFailCase(node.planNode.phrase, table.concat(node.errors,"\n")))
		end
		table.insert(buffer, teamCityLeaveCase(node.planNode.phrase))
	end
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

function TeamCityReporter.report(results)
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

return TeamCityReporter