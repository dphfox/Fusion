--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local scoped = require(Fusion.Memory.scoped)
local innerScope = require(Fusion.Memory.innerScope)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it

	it("should derive from scopes", function()
		local expect = getfenv().expect
		
		local scope = scoped({
			foo = "2"
		})

		local derived = innerScope(scope)

		expect(derived).to.be.a("table")
		expect(derived).never.to.equal(scope)
		expect(derived.foo).to.equal("2")
	end)

	it("should allow one additional method table", function()
		local expect = getfenv().expect
		
		local scope = scoped({
			foo = "2"
		})

		local derived = innerScope(scope, {
			bar = "5"
		})

		expect(derived.foo).to.equal("2")
		expect(derived.bar).to.equal("5")
		expect((scope :: any).bar).never.to.equal("5")
	end)

	it("should merge two method tables", function()
		local expect = getfenv().expect
		
		local scope = scoped({
			foo = "2"
		})

		local derived = innerScope(scope, {
			bar = "5"
		}, {
			baz = "10"
		})

		expect(derived.foo).to.equal("2")
		expect(derived.bar).to.equal("5")
		expect(derived.baz).to.equal("10")
		expect((scope :: any).bar).never.to.equal("5")
		expect((scope :: any).baz).never.to.equal("10")
	end)

	it("should merge three method tables", function()
		local expect = getfenv().expect
		
		local scope = scoped({
			foo = "2"
		})

		local derived = innerScope(scope, {
			bar = "5"
		}, {
			baz = "10"
		}, {
			garb = "15"
		})

		expect(derived.foo).to.equal("2")
		expect(derived.bar).to.equal("5")
		expect(derived.baz).to.equal("10")
		expect(derived.garb).to.equal("15")
		expect((scope :: any).bar).never.to.equal("5")
		expect((scope :: any).baz).never.to.equal("10")
		expect((scope :: any).garb).never.to.equal("15")
	end)

	it("should error on argument collision", function()
		local expect = getfenv().expect

		local scope = scoped({})
		
		expect(function()
			local originalA = {foo = "FOO", bar = "BAR", baz = "BAZ"}
			local originalB = {frob = "FROB", garb = "GARB", grok = "GROK"}
			local originalC = {grep = "GREP", grok = "GROK", grum = "GRUM"}
			innerScope(scope, originalA, originalB, originalC)
		end).to.throw("mergeConflict")
	end)

	it("should *not* error on collision with original scope", function()
		local expect = getfenv().expect

		local scope = scoped({foo = "FOO", bar = "BAR", baz = "BAZ"})
		
		expect(function()
			local originalA = {foo = "FOO", bar = "BAR", baz = "BAZ"}
			innerScope(scope, originalA)
		end).never.to.throw("mergeConflict")
	end)

	it("should *not* be able to outlive the original socpe", function()
		local expect = getfenv().expect

		local alive1 = true
		local alive2 = true
		local scope1 = scoped()
		table.insert(scope1, function()
			alive1 = false
		end)
		local scope2 = innerScope(scope1)
		table.insert(scope2, function()
			alive2 = false
		end)

		doCleanup(scope1)

		expect(alive1).to.equal(false)
		expect(alive2).to.equal(false)
	end)
end