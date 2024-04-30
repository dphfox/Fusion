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
		expect(scope[1]).to.equal(value)

		doCleanup(scope)
	end)

	it("is destroyable", function()
		local expect = getfenv().expect
		
		local value = Value({}, nil)
		expect(value.destroy).to.be.a("function")
		expect(function()
			value:destroy()
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
end
