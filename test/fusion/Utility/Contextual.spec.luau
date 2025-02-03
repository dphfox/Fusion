--!strict

local tiniest = require("../../lib/tiniest_for_roblox")

local Contextual = require("../../../src/Utility/Contextual")

return function(tiniest: tiniest.Configured): ()
	local test = tiniest.test
	local expect = tiniest.expect

	test("default value", function()
		local context = Contextual("foo")
		expect(context:now()).is("foo")
	end)

	test("time-based value", function()
		local context = Contextual("foo")
		expect(context:now()).is("foo")
		context:is("bar"):during(function()
			expect(context:now()).is("bar")
			context:is("baz"):during(function()
				expect(context:now()).is("baz")
				return nil
			end)
			expect(context:now()).is("bar")
			return nil
		end)
		expect(context:now()).is("foo")
	end)

	test("arguments", function()
		local context = Contextual("foo")
		context:is("bar"):during(function(a, b, c, d)
			expect(a).is("a")
			expect(b).is("b")
			expect(c).is("c")
			expect(d).is("d")
			return nil
		end, "a", "b", "c", "d")
	end)

	test("coroutine safety", function()
		local context = Contextual("foo")
		local coro1 = coroutine.create(function()
			context:is("bar"):during(function()
				expect(context:now()).is("bar")
				coroutine.yield()
				expect(context:now()).is("bar")
				return nil
			end)
		end)
		local coro2 = coroutine.create(function()
			context:is("baz"):during(function()
				expect(context:now()).is("baz")
				coroutine.yield()
				expect(context:now()).is("baz")
				return nil
			end)
		end)
		coroutine.resume(coro1)
		expect(context:now()).is("foo")
		coroutine.resume(coro2)
		expect(context:now()).is("foo")
		coroutine.resume(coro1)
		expect(context:now()).is("foo")
		coroutine.resume(coro2)
		expect(context:now()).is("foo")
	end)
end