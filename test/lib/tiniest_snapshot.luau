-- From dphfox/tiniest, licenced under MIT
--!strict

local tiniest_quote = require("tiniest_quote")
local tiniest = require("tiniest")
type Test = tiniest.Test

export type TestRunResult = tiniest.TestRunResult & {
	num_snapshots_updated: number,
	num_snapshots_obsolete: number
}
export type RunResult = tiniest.RunResult & {
	num_snapshots_updated: number,
	num_snapshots_obsolete: number
}

export type Options = {
	save_snapshots: nil | (key: string, values: {string}) -> (),
	load_snapshots: nil | (key: string) -> {string}?
}

type TestContext = {
	key: string,
	snapshots: {string},
	next_snapshot_index: number,
	num_updated: number
}

type RunContext = {
	num_updated: number,
	num_obsolete: number
}

local tiniest_snapshot = {}

function tiniest_snapshot.configure(
	options: Options
)
	
	local self = {}
	self.is_tiniest_plugin = true

	local function get_test_key(
		test: Test
	)
		local labels = {}
		for _, label in test.labels do
			label = label:lower():gsub("[^%w%s]", ""):gsub(" ", "_")
			table.insert(labels, label)
		end
		return table.concat(labels, ".")
	end

	local run_context: RunContext?
	local test_context: TestContext?

	function self.snapshot(
		x: unknown
	): ()
		if options.load_snapshots == nil then
			error("snapshot() is unavailable - snapshots have not been configured", 0)
		elseif run_context == nil or test_context == nil then
			error("snapshot() can only be used while a test is running with tiniest_snapshot", 0)
		end

		local snapshot_index = test_context.next_snapshot_index
		test_context.next_snapshot_index += 1

		local fresh_snapshot = tiniest_quote(x)
		local snapshot_on_disk = test_context.snapshots[snapshot_index]
		test_context.snapshots[snapshot_index] = fresh_snapshot
		
		if fresh_snapshot == snapshot_on_disk then
			return
		end

		if options.save_snapshots then
			run_context.num_updated += 1
			test_context.num_updated += 1
			test_context.snapshots[snapshot_index] = fresh_snapshot
		elseif snapshot_on_disk == nil then
			error({
				type = "tiniest.ErrorReport",
				message = "New snapshot() call needs to be saved.\nRun while saving snapshots to save it to disk.",
				trace = debug.traceback(nil, 2),
				code = {
					snippet = `snapshot({fresh_snapshot})`,
					line = debug.info(2, "l")
				}
			}, 0)
		else
			error({
				type = "tiniest.ErrorReport",
				message = "Snapshot does not match",
				trace = debug.traceback(nil, 2),
				code = {
					snippet = `snapshot({fresh_snapshot})\n\n-- snapshot on disk:\nsnapshot({snapshot_on_disk})`,
					line = debug.info(2, "l")
				}
			}, 0)
		end
	end

	function self.before_run(
		_, _
	): ()
		run_context = {
			num_updated = 0,
			num_obsolete = 0
		}
	end

	function self.after_run(
		original_run_result: tiniest.RunResult,
		_
	): ()
		assert(run_context ~= nil)
		local run_result = original_run_result :: RunResult
		run_result.num_snapshots_updated = run_context.num_updated
		run_result.num_snapshots_obsolete = run_context.num_obsolete
		run_context = nil
	end

	function self.before_test(
		test: Test,
		_
	): ()
		assert(run_context ~= nil)
		local key = get_test_key(test)
		test_context = {
			key = key,
			snapshots = options.load_snapshots and options.load_snapshots(key) or {},
			next_snapshot_index = 1,
			num_updated = 0
		}
	end

	function self.after_test(
		_,
		original_run_result: tiniest.TestRunResult,
		_
	): ()
		assert(run_context ~= nil)
		assert(test_context ~= nil)
		local run_result = original_run_result :: TestRunResult
		run_result.num_snapshots_updated = test_context.num_updated
		run_result.num_snapshots_obsolete = test_context.next_snapshot_index - #test_context.snapshots - 1
		run_context.num_obsolete += run_result.num_snapshots_obsolete
		if test_context.num_updated > 0 and options.save_snapshots ~= nil then
			options.save_snapshots(test_context.key, test_context.snapshots)
		end
		test_context = nil
	end

	function self.add_annotations(
		original_run_result: tiniest.TestRunResult,
		_,
		add_annotation: (string) -> ()
	)
		local run_result = original_run_result :: TestRunResult
		if run_result.num_snapshots_updated > 0 then
			add_annotation(`{run_result.num_snapshots_updated} snapshot(s) updated`)
		end
		if run_result.num_snapshots_obsolete > 0 then
			add_annotation(`{run_result.num_snapshots_obsolete} snapshot(s) obsolete`)
		end
	end

	function self.add_line_items(
		original_run_result: tiniest.RunResult,
		_,
		add_line_item: (string, string) -> ()
	)
		local run_result = original_run_result :: RunResult
		if run_result.num_snapshots_updated > 0 then
			add_line_item("Updated snapshots", tostring(run_result.num_snapshots_updated))
		end
		if run_result.num_snapshots_obsolete > 0 then
			add_line_item("Obsolete snapshots", tostring(run_result.num_snapshots_obsolete))
		end
	end

	return self
end

return tiniest_snapshot