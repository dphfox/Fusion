-- From dphfox/tiniest, licenced under MIT
--!strict

local tiniest_plugin = require("./tiniest_plugin")

type Context = DescribeContext | RunContext

type DescribeContext = {
	type: "describe",
	labels: {string},
	add_test: (Test) -> ()
}

type RunContext = {
	type: "run"
}

export type ErrorReport = {
	type: "tiniest.ErrorReport",
	message: string,
	trace: string,
	code: {
		snippet: string,
		line: string
	}?
}

export type Test = {
	labels: {string},
	run: () -> ()
}

export type RunResult = {
	tests: {Test},
	status_tally: {
		pass: number,
		fail: number
	},
	individual: {[Test]: TestRunResult}
}

export type TestRunResult = PassTestRunResult | FailTestRunResult

export type PassTestRunResult = {
	status: "pass"
}

export type FailTestRunResult = {
	status: "fail",
	error: ErrorReport
}

export type Options = {
	plugins: nil | {tiniest_plugin.Plugin}
}

export type RunOptions = {}

local function catch_errors(func: any, ...)
	local outer_trace
	local function handler(message)
		local report: ErrorReport
		if typeof(message) == "table" and message.type == "tiniest.ErrorReport" then
			report = message :: ErrorReport
		else
			report = {
				type = "tiniest.ErrorReport",
				message = tostring(message),
				trace = debug.traceback(nil, 2)
			}
		end
		local from, to = string.find(report.trace, outer_trace, 1, true)
		if from ~= nil and to ~= nil then
			report.trace = report.trace:sub(1, from - 1) .. report.trace:sub(to + 1)
		end
		return report
	end
	outer_trace = debug.traceback(); return xpcall(func, handler, ...)
end

local tiniest = {}

function tiniest.configure(
	options: Options
)

	local plugins = tiniest_plugin.configure(options.plugins)

	local get_context, with_root_context, with_inner_context
	do
		local current_context: Context? = nil

		function get_context(): Context
			assert(current_context ~= nil, "This function can only be called from inside of a test suite")
			return current_context
		end

		function with_root_context(
			root_context: Context,
			inner: (Context) -> ()
		): ()
			assert(current_context == nil, "This function can't be called from inside of a test suite")
			current_context = root_context
			local ok, err = catch_errors(inner :: any, root_context)
			current_context = nil
			if not ok then
				error(err.message, 0)
			end
		end

		function with_inner_context(
			make_context: (Context) -> Context,
			inner: (Context) -> ()
		): ()
			local outer_context = get_context()
			local inner_context = make_context(outer_context)
			current_context = inner_context
			local ok, err = catch_errors(inner :: any, inner_context)
			current_context = outer_context
			if not ok then
				error(err.message, 0)
			end
		end
	end

	local self = {}

	function self.describe(
		label: string,
		inner: () -> ()
	): ()
		with_inner_context(function(outer_context: Context): Context
			assert(outer_context.type == "describe", "This function can only be called outside of tests")
			local context = table.clone(outer_context)
			context.labels = table.clone(context.labels)
			table.insert(context.labels, label)
			return context
		end, inner)
	end

	function self.test(
		label: string,
		run: () -> ()
	): ()
		local context = get_context()
		assert(context.type == "describe", "This function can only be called outside of tests")
		local labels = table.clone(context.labels)
		table.insert(labels, label)
		local test: Test = {
			labels = labels,
			run = run
		}
		context.add_test(test)
	end

	function self.collect_tests(
		inner: () -> ()
	): {Test}
		local tests = {}
		local context: Context = {
			type = "describe",
			labels = {},
			add_test = function(test)
				table.insert(tests, test)
			end
		}
		with_root_context(context, inner)
		return tests
	end

	function self.run_tests(
		tests: {Test},
		run_options: RunOptions
	): RunResult
		plugins.notify("before_run", tests, run_options)

		local context: Context = {
			type = "run"
		}
		
		local individual = {}
		for _, test in tests do
			plugins.notify("before_test", test, run_options)
			local _, test_run_result = xpcall(
				function()
					with_root_context(context, test.run)
					local pass: TestRunResult = {
						status = "pass"
					}
					return pass
				end,
				function(message)
					if typeof(message) == "table" and message.type == "tiniest.ErrorReport" then
						local fail: TestRunResult = {
							status = "fail",
							error = message :: ErrorReport
						}
						return fail
					else
						local error: ErrorReport = {
							type = "tiniest.ErrorReport",
							message = tostring(message),
							trace = debug.traceback()
						}
						local fail: TestRunResult = {
							status = "fail",
							error = error
						}
						return fail
					end
				end
			)
			plugins.notify("after_test", test, test_run_result, run_options)
			individual[test] = test_run_result
		end

		local status_tally = {
			pass = 0,
			fail = 0
		}

		for _, result in individual do
			status_tally[result.status] += 1
		end

		local result: RunResult = {
			tests = tests,
			status_tally = status_tally,
			individual = individual
		}
		plugins.notify("after_run", result, run_options)

		return result
	end

	return self
end

return tiniest