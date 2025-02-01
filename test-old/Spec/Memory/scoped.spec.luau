--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local scoped = require(Fusion.Memory.scoped)

return function()
	local it = getfenv().it

	it("should accept zero arguments", function()
		local expect = getfenv().expect
		
		local scope = scoped()

		expect(scope).to.be.a("table")
		expect(#scope).to.equal(0)
	end)

	it("should accept single arguments", function()
		local expect = getfenv().expect
		
		local original = {foo = "FOO", bar = "BAR", baz = "BAZ"}
		local scope = scoped(original)

		expect(scope).to.be.a("table")
		expect(scope).to.never.equal(original)
		for key, value in original do
			expect((scope :: any)[key]).to.equal(value)
		end
	end)

	it("should merge two arguments", function()
		local expect = getfenv().expect
		
		local originalA = {foo = "FOO", bar = "BAR", baz = "BAZ"}
		local originalB = {frob = "FROB", garb = "GARB", grok = "GROK"}
		local scope = scoped(originalA, originalB)

		expect(scope).to.be.a("table")
		for _, original in {originalA :: any, originalB} do
			expect(scope).to.never.equal(original)
			for key, value in original do
				expect((scope :: any)[key]).to.equal(value)
			end
			for key, value in original do
				expect((scope :: any)[key]).to.equal(value)
			end
			for key, value in original do
				expect((scope :: any)[key]).to.equal(value)
			end
		end
	end)

	it("should merge three arguments", function()
		local expect = getfenv().expect
		
		local originalA = {foo = "FOO", bar = "BAR", baz = "BAZ"}
		local originalB = {frob = "FROB", garb = "GARB", grok = "GROK"}
		local originalC = {grep = "GREP", bork = "BORK", grum = "GRUM"}
		local scope = scoped(originalA, originalB, originalC)

		expect(scope).to.be.a("table")
		for _, original in {originalA :: any, originalB, originalC} do
			expect(scope).to.never.equal(original)
			for key, value in original do
				expect((scope :: any)[key]).to.equal(value)
			end
			for key, value in original do
				expect((scope :: any)[key]).to.equal(value)
			end
			for key, value in original do
				expect((scope :: any)[key]).to.equal(value)
			end
		end
	end)

	it("should error on collision", function()
		local expect = getfenv().expect
		
		expect(function()
			local originalA = {foo = "FOO", bar = "BAR", baz = "BAZ"}
			local originalB = {frob = "FROB", garb = "GARB", grok = "GROK"}
			local originalC = {grep = "GREP", grok = "GROK", grum = "GRUM"}
			scoped(originalA, originalB, originalC)
		end).to.throw("mergeConflict")
	end)
end