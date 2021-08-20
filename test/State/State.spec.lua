local Package = game:GetService("ReplicatedStorage").Fusion
local State = require(Package.State.State)

return function()
	it("should construct a State object", function()
		local state = State()

		expect(state).to.be.a("table")
		expect(state.type).to.equal("State")
		expect(state.kind).to.equal("State")
	end)

	it("should be able to store arbitrary values", function()
		local state = State(0)
		expect(state:get()).to.equal(0)

		state:set(10)
		expect(state:get()).to.equal(10)

		state:set(State)
		expect(state:get()).to.equal(State)
	end)
end