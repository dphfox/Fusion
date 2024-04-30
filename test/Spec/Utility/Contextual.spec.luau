--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local Contextual = require(Fusion.Utility.Contextual)

return function()
	local it = getfenv().it

	it("should construct a Contextual object", function()
		local expect = getfenv().expect
		
		local ctx = Contextual(nil)

		expect(ctx).to.be.a("table")
		expect(ctx.type).to.equal("Contextual")
	end)

	it("should provide its default value", function()
		local expect = getfenv().expect
		
		local ctx = Contextual("foo")

		expect(ctx:now()).to.equal("foo")
	end)

	it("should correctly scope temporary values", function()
		local expect = getfenv().expect
		
		local ctx = Contextual("foo")

		expect(ctx:now()).to.equal("foo")

		ctx:is("bar"):during(function()
			expect(ctx:now()).to.equal("bar")

			ctx:is("baz"):during(function()
				expect(ctx:now()).to.equal("baz")
				return nil
			end)

			expect(ctx:now()).to.equal("bar")
			return nil
		end)

		expect(ctx:now()).to.equal("foo")
	end)

	it("should allow for argument passing", function()
		local expect = getfenv().expect
		
		local ctx = Contextual("foo")

		local function test(a, b, c, d)
			expect(a).to.equal("a")
			expect(b).to.equal("b")
			expect(c).to.equal("c")
			expect(d).to.equal("d")
			return nil
		end

		ctx:is("bar"):during(test, "a", "b", "c", "d")
	end)

	it("should not interfere across coroutines", function()
		local expect = getfenv().expect
		
		local ctx = Contextual("foo")

		local coro1 = coroutine.create(function()
			ctx:is("bar"):during(function()
				expect(ctx:now()).to.equal("bar")
				coroutine.yield()
				expect(ctx:now()).to.equal("bar")
				return nil
			end)
		end)

		local coro2 = coroutine.create(function()
			ctx:is("baz"):during(function()
				expect(ctx:now()).to.equal("baz")
				coroutine.yield()
				expect(ctx:now()).to.equal("baz")
				return nil
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