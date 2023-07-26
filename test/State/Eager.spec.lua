local Package = game:GetService("ReplicatedStorage").Fusion
local Computed = require(Package.State.Computed)
local ForValues = require(Package.State.ForValues)
local ForPairs = require(Package.State.ForPairs)
local ForKeys = require(Package.State.ForKeys)
local Eager = require(Package.State.Eager)
local Value = require(Package.State.Value)
local peek = require(Package.State.peek)

local waitForGC = require(script.Parent.Parent.Utility.waitForGC)

return function()
	it("should force Computed objects to be eager", function()
		local state = Value(2)
		local eagerComputed = Eager(Computed(function(use)
			return use(state)
		end))

		expect(eagerComputed._value).to.equal(2)
		
		state:set(4)

		expect(eagerComputed._value).to.equal(4)
	end)

	itSKIP("should force ForKeys objects to be eager", function()
		local state = Value({
			one = 1,
			two = 2,
		})
		local eagerForKeys = Eager(ForKeys(state, function(use, key)
			local newKey = string.upper(key)
			return newKey
		end))

		expect(eagerForKeys._value).to.be.a("table")
		expect(eagerForKeys._value.ONE).to.equal(1)
		expect(eagerForKeys._value.TWO).to.equal(2)
		
		state:set({
			three = 3,
			four = 4,
		})

		expect(eagerForKeys._value).to.be.a("table")
		expect(eagerForKeys._value.THREE).to.equal(3)
		expect(eagerForKeys._value.FOUR).to.equal(4)
	end)

	itSKIP("should force ForValues objects to be eager", function()
		local state = Value({
			[1] = "one",
			[2] = "two",
		})
		local eagerForValues = Eager(ForValues(state, function(use, value)
			local newValue = string.upper(value)
			return newValue
		end))

		expect(eagerForValues._value).to.be.a("table")
		expect(eagerForValues._value[1]).to.equal("ONE")
		expect(eagerForValues._value[2]).to.equal("TWO")
		
		state:set({
			[3] = "three",
			[4] = "four",
		})

		expect(eagerForValues._value).to.be.a("table")
		expect(eagerForValues._value[3]).to.equal("THREE")
		expect(eagerForValues._value[4]).to.equal("FOUR")
	end)

	itSKIP("should force ForPairs objects to be eager", function()
		local state = Value({
			one = 1,
			two = 2,
		})
		local eagerForPairs = Eager(ForPairs(state, function(use, key, value)
			local newKey, newValue = value, string.upper(key)
			return newKey, newValue
		end))

		expect(eagerForPairs._value).to.be.a("table")
		expect(eagerForPairs._value[1]).to.equal("ONE")
		expect(eagerForPairs._value[2]).to.equal("TWO")
		
		state:set({
			three = 3,
			four = 4,
		})

		expect(eagerForPairs._value).to.be.a("table")
		expect(eagerForPairs._value[3]).to.equal("THREE")
		expect(eagerForPairs._value[4]).to.equal("FOUR")
	end)
end
