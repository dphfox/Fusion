local RunService = game:GetService("RunService")

local Package = game:GetService("ReplicatedStorage").Fusion
local ForPairs = require(Package.State.ForPairs)
local Value = require(Package.State.Value)
local peek = require(Package.State.peek)

return function()
	it("should construct a ForPairs object", function()
		local forPairs = ForPairs({}, function(use) end)

		expect(forPairs).to.be.a("table")
		expect(forPairs.type).to.equal("State")
		expect(forPairs.kind).to.equal("ForPairs")
	end)

	it("should calculate and retrieve its value", function()
		local computedPair = ForPairs({ ["foo"] = "bar" }, function(use, key, value)
			return key .. "baz", value .. "biz"
		end)

		local state = peek(computedPair)

		expect(state["foobaz"]).to.be.ok()
		expect(state["foobaz"]).to.equal("barbiz")
	end)

	it("should not recalculate its KO/VO in response to an unchanged KI/VI", function()
		local state = Value({
			["foo"] = "bar",
		})

		local computedPair = ForPairs(state, function(use, key, value)
			return key .. "biz", { value }
		end)

		local foobiz = peek(computedPair)["foobiz"]

		state:set({
			["foo"] = "bar",
			["baz"] = "bar",
		})

		expect(peek(computedPair)["foobiz"]).to.equal(foobiz)
	end)

	it("should call the destructor when a key/value pair gets changed", function()
		local state = Value({
			["foo"] = "bar",
			["baz"] = "bar",
		})

		local destructions = 0

		local computedPair = ForPairs(state, function(use, key, value)
			return key .. "biz", value .. "biz"
		end, function(key, value)
			destructions += 1
		end)

		state:set({
			["foo"] = "bar",
		})

		expect(destructions).to.equal(1)

		state:set({
			["baz"] = "bar",
		})

		expect(destructions).to.equal(2)

		state:set({
			["foo"] = "bar",
			["baz"] = "bar",
		})

		expect(destructions).to.equal(2)

		state:set({})

		expect(destructions).to.equal(4)
	end)

	it(
		"should not call the destructor when an output key/value pair still remains with a new input key/value pair",
		function()
			local state = Value({
				["foo"] = "bar",
			})

			local destructions = 0

			local computedPair = ForPairs(state, function(use, key, value)
				return value, value
			end, function(key, value)
				destructions += 1
			end)

			state:set({
				["baz"] = "bar",
			})

			expect(destructions).to.equal(0)

			state:set({
				["biz"] = "baz",
			})

			expect(destructions).to.equal(1)

			state:set({
				["foo"] = "bar",
				["biz"] = "baz",
			})

			expect(destructions).to.equal(1)

			state:set({
				["foo"] = "baz",
				["biz"] = "bar",
			})

			expect(destructions).to.equal(1)

			state:set({
				["biz"] = "bar",
			})

			expect(destructions).to.equal(2)

			state:set({})

			expect(destructions).to.equal(3)
		end
	)

	it("should throw if there is a key collision", function()
		expect(function()
			local state = Value({
				["foo"] = "bar",
				["baz"] = "bar",
			})

			local computed = ForPairs(state, function(use, key, value)
				return value, key
			end)
		end).to.throw("forPairsKeyCollision")

		local state = Value({
			["foo"] = "bar",
		})

		local computed = ForPairs(state, function(use, key, value)
			return value, key
		end)

		expect(function()
			state:set({
				["foo"] = "bar",
				["baz"] = "bar",
			})
		end).to.throw("forPairsKeyCollision")
	end)

	it("should call the destructor with meta data", function()
		local state = Value({
			["foo"] = "bar",
		})

		local destructions = 0

		local computedPair = ForPairs(state, function(use, key, value)
			local newKey = key .. "biz"
			local newValue = value .. "biz"

			return newKey, newValue, newKey .. newValue
		end, function(key, value, meta)
			expect(meta).to.equal(key .. value)
			destructions += 1
		end)

		state:set({
			["foo"] = "baz",
		})

		-- this verifies that the meta expectation passed
		expect(destructions).to.equal(1)

		state:set({})

		-- this verifies that the meta expectation passed
		expect(destructions).to.equal(2)
	end)

	it("should recalculate its value in response to State objects", function()
		local currentNumber = Value({ ["foo"] = 2 })
		local doubled = ForPairs(currentNumber, function(use, key, value)
			return key .. "bar", value * 2
		end)

		expect(peek(doubled)["foobar"]).to.equal(4)

		currentNumber:set({ ["foo"] = 4 })
		expect(peek(doubled)["foobar"]).to.equal(8)
	end)

	it("should recalculate its value in response to ForPairs objects", function()
		local currentNumbers = Value({ 1, 2 })
		local doubled = ForPairs(currentNumbers, function(use, key, value)
			return key * 2, value * 2
		end)
		local tripled = ForPairs(doubled, function(use, key, value)
			return key * 2, value * 2
		end)

		expect(peek(tripled)[4]).to.equal(4)
		expect(peek(tripled)[8]).to.equal(8)

		currentNumbers:set({ 2, 4 })
		expect(peek(tripled)[4]).to.equal(8)
		expect(peek(tripled)[8]).to.equal(16)
	end)

	itSKIP("should not corrupt dependencies after an error", function()
		-- needs rewrite
	end)

	it("should garbage-collect unused objects", function()
		local state = Value({ 2 })

		local counter = 0

		do
			local computedPairs = ForPairs(state, function(use, key, value)
				counter += 1
				return key, value
			end)
		end

		state:set({ 5 })

		expect(counter).to.equal(1)
	end)

	it("should not garbage-collect objects in use", function()
		local state = Value({ 2 })
		local computed2

		local counter = 0

		do
			local computed = ForPairs(state, function(use, key, value)
				counter += 1
				return key, value
			end)

			computed2 = ForPairs(computed, function(use, key, value)
				return key, value
			end)
		end

		state:set({ 5 })

		expect(counter).to.equal(2)
	end)
end
