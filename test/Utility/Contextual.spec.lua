local Package = game:GetService("ReplicatedStorage").Fusion
local Contextual = require(Package.Utility.Contextual)

return function()
	it("should construct a Contextual object", function()
		local ctx = Contextual()

		expect(ctx).to.be.a("table")
		expect(ctx.type).to.equal("Contextual")
	end)

	it("should provide its default value", function()
		local ctx = Contextual("foo")

		expect(ctx:now()).to.equal("foo")
	end)

	it("should correctly scope temporary values", function()
		local ctx = Contextual("foo")

		expect(ctx:now()).to.equal("foo")

		ctx:is("bar"):during(function()
			expect(ctx:now()).to.equal("bar")

			ctx:is("baz"):during(function()
				expect(ctx:now()).to.equal("baz")
			end)

			expect(ctx:now()).to.equal("bar")
		end)

		expect(ctx:now()).to.equal("foo")
	end)

	it("should allow for argument passing", function()
		local ctx = Contextual("foo")

		local function test(a, b, c, d)
			expect(a).to.equal("a")
			expect(b).to.equal("b")
			expect(c).to.equal("c")
			expect(d).to.equal("d")
		end

		ctx:is("bar"):during(test, "a", "b", "c", "d")
	end)

	it("should not interfere across coroutines", function()
		local ctx = Contextual("foo")

		local coro1 = coroutine.create(function()
			ctx:is("bar"):during(function()
				expect(ctx:now()).to.equal("bar")
				coroutine.yield()
				expect(ctx:now()).to.equal("bar")
			end)
		end)

		local coro2 = coroutine.create(function()
			ctx:is("baz"):during(function()
				expect(ctx:now()).to.equal("baz")
				coroutine.yield()
				expect(ctx:now()).to.equal("baz")
			end)
		end)

		coroutine.resume(coro1)
		expect(ctx:now()).to.equal("foo")
		coroutine.resume(coro2)
		expect(ctx:now()).to.equal("foo")
		coroutine.resume(coro1)
		expect(ctx:now()).to.equal("foo")
		coroutine.resume(coro2)
		expect(ctx:now()).to.equal("foo")
	end)
end