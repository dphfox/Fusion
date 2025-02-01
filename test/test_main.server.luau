--!strict

local tiniest = require("./lib/tiniest_for_roblox").configure({})

local tests = tiniest.collect_tests(function()
	local describe = tiniest.describe
	local test = tiniest.test
	local expect = tiniest.expect

	describe("something cool", function()
		test("it works", function()
			expect(2 + 2).is(5)
		end)
	end)
end)
tiniest.run_tests(tests, {})