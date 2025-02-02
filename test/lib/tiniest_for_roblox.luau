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

export type CollectOptions = {
	file_name_pattern: string?
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

	function self.collect_tests_from_hierarchy(
		ancestor: Instance,
		declared_collect_options: CollectOptions?
	)
		local collect_options: CollectOptions = declared_collect_options or {}
		local file_name_pattern = collect_options.file_name_pattern or "%.spec$"
		local function discover(
			ancestor: Instance
		): ()
			self.describe(ancestor.Name, function()
				if ancestor:IsA("ModuleScript") and ancestor.Name:match(file_name_pattern) then
					local requireOk, module = pcall(require, ancestor)
					if not requireOk then
						error(`Error while requiring {ancestor:GetFullName()}`, 0)
					elseif typeof(module) ~= "function" then
						error(`Did not get a function from {ancestor:GetFullName()}`, 0)
					end
					local collectOk, err = pcall(module, self)
					if not collectOk then
						error(err, 0)
					end
				end
				local children = ancestor:GetChildren()
				if #children > 0 then
					table.sort(children, function(a, b)
						return a.Name < b.Name
					end)
					for _, child in children do
						discover(child)
					end
				end
			end)
			
		end
		return self.collect_tests(function()
			discover(ancestor)
		end)
	end

	return self
end

export type Configured = typeof(tiniest_for_roblox.configure({}))

return tiniest_for_roblox