--!strict

local tiniest = require("../../lib/tiniest_for_roblox")

local Safe = require("../../../src/Utility/Safe")

return function(tiniest: tiniest.Configured): ()
	local test = tiniest.test
	local expect = tiniest.expect

	test("success", function()
		expect(
			Safe({
				try = function()
					return "foo"
				end,
				fallback = function()
					return "bar"
				end
			})
		).is("foo")
	end)

	test("failure", function()
		expect(
			Safe({
				try = function()
					error("garb", 0)
					return "foo"
				end,
				fallback = function()
					return "bar"
				end
			})
		).is("bar")
	end)

	test("error reporting", function()
		Safe({
			try = function()
				error("garb", 0)
				return nil
			end,
			fallback = function(err)
				expect(err).is("garb")
				return nil
			end
		})
	end)
	
end