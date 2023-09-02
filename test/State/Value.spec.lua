local Package = game:GetService("ReplicatedStorage").Fusion
local Value = require(Package.State.Value)
local ForValues = require(Package.State.ForValues)
local peek = require(Package.State.peek)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	it("should construct in scopes", function()
		local scope = {}
		local value = Value(scope)

		expect(value).to.be.a("table")
		expect(value.type).to.equal("State")
		expect(value.kind).to.equal("Value")
		expect(scope[1]).to.equal(value)

		doCleanup(scope)
	end)

	it("should be settable", function()
		local scope = {}
		local value = Value(scope, 0)
		expect(peek(value)).to.equal(0)

		value:set(10)
		expect(peek(value)).to.equal(10)

		value:set("foo")
		expect(peek(value)).to.equal("foo")

		doCleanup(scope)
	end)

	it("should be destroyable", function()
		local value = Value({})
		expect(value.destroy).to.be.a("function")
		expect(function()
			value:destroy()
		end).to.never.throw()
	end)
end
