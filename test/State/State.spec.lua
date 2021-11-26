local Package = game:GetService("ReplicatedStorage").Fusion
local Value = require(Package.State.Value)

return function()
	it("should construct a State object", function()
		local state = Value()

		expect(state).to.be.a("table")
		expect(state.type).to.equal("State")
		expect(state.kind).to.equal("State")
	end)

	it("should be able to store arbitrary values", function()
		local state = Value(0)
		expect(state:get()).to.equal(0)

		state:set(10)
		expect(state:get()).to.equal(10)

		state:set(Value)
		expect(state:get()).to.equal(Value)
	end)
end