--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local Value = require(Fusion.State.Value)
local peek = require(Fusion.State.peek)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it

	it("constructs in scopes", function()
		local expect = getfenv().expect
		
		local scope = {}
		local value = Value(scope, nil)

		expect(value).to.be.a("table")
		expect(value.type).to.equal("State")
		expect(value.kind).to.equal("Value")
		expect(table.find(scope, value.oldestTask :: any)).never.to.equal(nil)

		doCleanup(scope)
	end)

	it("is destroyable", function()
		local expect = getfenv().expect
		
		local value = Value({}, nil)
		expect(function()
			doCleanup(value)
		end).to.never.throw()
	end)

	it("accepts a default value", function()
		local expect = getfenv().expect
		
		local scope = {}
		local value = Value(scope, 5)
		expect(peek(value)).to.equal(5)
		doCleanup(scope)
	end)

	it("is settable", function()
		local expect = getfenv().expect
		
		local scope = {}
		local value = Value(scope, 0 :: string | number)
		expect(peek(value)).to.equal(0)

		value:set(10)
		expect(peek(value)).to.equal(10)

		value:set("foo")
		expect(peek(value)).to.equal("foo")

		doCleanup(scope)
	end)

	it("updates its last changed time on set", function()
		local expect = getfenv().expect
		
		local scope = {}
		local value = Value(scope, 1)

		local before = value.lastChange
		value:set(2)
		expect(value.lastChange).never.to.equal(before)

		before = value.lastChange
		value:set(3)
		expect(value.lastChange).never.to.equal(before)

		before = value.lastChange
		value:set(4)
		expect(value.lastChange).never.to.equal(before)

		doCleanup(scope)
	end)

	it("is always valid", function()
		local expect = getfenv().expect
		
		local scope = {}
		local value = Value(scope, 1)
		expect(value.validity).to.equal("valid")

		value:set(2)
		expect(value.validity).to.equal("valid")

		value:set(3)
		expect(value.validity).to.equal("valid")
		
		value:set(4)
		expect(value.validity).to.equal("valid")
		
		doCleanup(scope)
	end)

	it("always returns the set value", function()
		local expect = getfenv().expect
		
		local scope = {}
		local value = Value(scope, 0 :: string | number)

		local foo = value:set(10)
		expect(foo).to.equal(10)

		local bar = value:set(10)
		expect(bar).to.equal(10)

		local baz = value:set(25)
		expect(baz).to.equal(25)

		local garb = value:set(25)
		expect(garb).to.equal(25)

		doCleanup(scope)
	end)
end
