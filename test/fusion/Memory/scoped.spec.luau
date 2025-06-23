--!strict

local tiniest = require("../../lib/tiniest_for_roblox")

local scoped = require("../../../src/Memory/scoped")

return function(tiniest: tiniest.Configured): ()
	local describe = tiniest.describe
	local test = tiniest.test
	local expect = tiniest.expect

	test("basic", function()
		local scope = scoped()
		expect(scope).is_a("table")
		expect((next(scope))).never_exists()
	end)

	describe("associated table", function()
		test("single", function()
			local assoc = { foo = {}, bar = {} }
			local scope = scoped(assoc)
			expect(scope).never_is(assoc)
			expect(scope.foo).is(assoc.foo)
			expect(scope.bar).is(assoc.bar)
		end)

		test("multiple", function()
			local assoc1 = { foo = {} }
			local assoc2 = { bar = {} }
			local assoc3 = { baz = {} }
			local scope = scoped(assoc1, assoc2, assoc3)
			expect(scope).never_is(assoc1)
			expect(scope).never_is(assoc2)
			expect(scope).never_is(assoc3)
			expect(scope.foo).is(assoc1.foo)
			expect(scope.bar).is(assoc2.bar)
			expect(scope.baz).is(assoc3.baz)
		end)

		test("collision", function()
			local assoc1 = { foo = {} }
			local assoc2 = { foo = {} }
			local assoc3 = { foo = {} }
			expect(function()
				scoped(assoc1, assoc2, assoc3)
			end).fails_with("mergeConflict")
		end)
	end)
end