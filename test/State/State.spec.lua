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

    it("should be able to reset to it's initial value", function()
        local initialValue = 10
        local state = State(initialValue)

        state:set(0)
        expect(state:get()).never.to.equal(initialValue)

        state:reset()
        expect(state:get()).to.equal(initialValue)
    end)
end