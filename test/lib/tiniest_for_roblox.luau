-- From dphfox/tiniest, licenced under MIT
--!strict

local tiniest_expect = require("./tiniest_expect")
local tiniest_time = require("./tiniest_time")
local tiniest_pretty = require("./tiniest_pretty")
local tiniest = require("./tiniest")

export type Options = {
	snapshot_path: string?,
	save_snapshots: boolean?,
	pretty: nil | {
		disable_emoji: boolean?,
		disable_unicode: boolean?,
		disable_output: nil | {
			after_run: boolean?
		}
	}
}

local tiniest_for_roblox = {}

function tiniest_for_roblox.configure(
	options: Options
)
	local self = {}

	self.expect = tiniest_expect.expect

	local tiniest_time = tiniest_time.configure({
		get_timestamp = os.clock
	})

	local tiniest_pretty = tiniest_pretty.configure({
		disable_colour = true,
		disable_emoji = options.pretty and options.pretty.disable_emoji,
		disable_unicode = options.pretty and options.pretty.disable_unicode,
		disable_output = options.pretty and options.pretty.disable_output,
		plugins = { tiniest_time :: any }
	})
	self.format_run = tiniest_pretty.format_run

	local tiniest = tiniest.configure({
		plugins = { tiniest_time :: any, tiniest_pretty }
	}) 
	self.describe = tiniest.describe
	self.test = tiniest.test
	self.collect_tests = tiniest.collect_tests
	self.run_tests = tiniest.run_tests

	return self
end

return tiniest_for_roblox