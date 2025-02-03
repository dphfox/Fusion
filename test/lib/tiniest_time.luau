-- From dphfox/tiniest, licenced under MIT
--!strict

local tiniest = require("./tiniest")
local tiniest_pretty = require("./tiniest_pretty")
type Test = tiniest.Test

export type TestRunResult = tiniest.TestRunResult & {
	duration: number
}
export type RunResult = tiniest.RunResult & {
	duration: number
}

export type Options = {
	get_timestamp: () -> number
}

local tiniest_time = {}

local function format_duration(
	seconds: number,
	options: tiniest_pretty.Options
): string
	local SECOND = 1
	local MILLISECOND = SECOND / 1000
	local MICROSECOND = MILLISECOND / 1000
	local suffix = {
		micro = if options.disable_unicode then "u" else "µ",
		milli = "m",
	}

	if seconds < 100 * MICROSECOND then
		return `{math.ceil(seconds / MICROSECOND * 100) / 100}{suffix.micro}s`
	elseif seconds < 100 * MILLISECOND then
		return `{math.ceil(seconds / MILLISECOND * 100) / 100}{suffix.milli}s`
	else
		return `{math.ceil(seconds * 100) / 100}s`
	end
end

function tiniest_time.configure(
	options: Options
)
	
	local self = {}
	self.is_tiniest_plugin = true

	local start_times = {}

	function self.before_run(
		tests: {Test},
		_
	): ()
		start_times[tests] = options.get_timestamp()
	end

	function self.after_run(
		original_run_result: tiniest.RunResult,
		_
	): ()
		local run_result = original_run_result :: RunResult
		run_result.duration = options.get_timestamp() - start_times[run_result.tests]
		start_times[run_result.tests] = nil
	end

	function self.before_test(
		test: Test,
		_
	): ()
		start_times[test] = options.get_timestamp()
	end

	function self.after_test(
		test: Test,
		original_run_result: tiniest.TestRunResult,
		_
	): ()
		local run_result = original_run_result :: TestRunResult
		run_result.duration = options.get_timestamp() - start_times[test]
		start_times[test] = nil
	end

	function self.add_annotations(
		original_run_result: tiniest.TestRunResult,
		options: tiniest_pretty.Options,
		add_annotation: (string) -> ()
	)
		local run_result = original_run_result :: TestRunResult
		add_annotation(format_duration(run_result.duration, options))
	end

	function self.add_line_items(
		original_run_result: tiniest.RunResult,
		options: tiniest_pretty.Options,
		add_line_item: (string, string) -> ()
	)
		local run_result = original_run_result :: RunResult
		add_line_item("Time to run", format_duration(run_result.duration, options))
	end

	return self
end

return tiniest_time