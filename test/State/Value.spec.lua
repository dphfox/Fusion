local Package = game:GetService("ReplicatedStorage").Fusion
local Value = require(Package.State.Value)

return function()
	it("should construct a Value object", function()
		local value = Value()

		expect(value).to.be.a("table")
		expect(value.type).to.equal("State")
		expect(value.kind).to.equal("Value")
	end)

	it("should be able to store arbitrary values", function()
		local value = Value(0)
		expect(value:get()).to.equal(0)

		value:set(10)
		expect(value:get()).to.equal(10)

		value:set(Value)
		expect(value:get()).to.equal(Value)
	end)
end