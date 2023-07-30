local RunService = game:GetService("RunService")

local Package = game:GetService("ReplicatedStorage").Fusion
local ForKeys = require(Package.State.ForKeys)
local Eager = require(Package.State.Eager)
local Value = require(Package.State.Value)
local peek = require(Package.State.peek)

local waitForGC = require(script.Parent.Parent.Utility.waitForGC)

return function()
	it("should construct a ForKeys object", function()
		local forKeys = ForKeys({}, function(use) end)

		expect(forKeys).to.be.a("table")
		expect(forKeys.type).to.equal("State")
		expect(forKeys.kind).to.equal("ForKeys")
	end)

	it("should calculate and retrieve its value", function()
		local computedPair = ForKeys({ ["foo"] = true }, function(use, key)
			return key .. "baz"
		end)

		local state = peek(computedPair)

		expect(state["foobaz"]).to.be.ok()
		expect(state["foobaz"]).to.equal(true)
	end)

	it("should not recalculate its KO in response to an unchanged KI", function()
		local state = Value({
			["foo"] = "bar",
		})

		local calculations = 0

		local computedPair = ForKeys(state, function(use, key)
			calculations += 1
			return key
		end)

		peek(computedPair)

		expect(calculations).to.equal(1)

		state:set({
			["foo"] = "biz",
			["baz"] = "bar",
		})
		
		peek(computedPair)

		expect(calculations).to.equal(2)
	end)

	it("should call the destructor when a key gets removed", function()
		local state = Value({
			["foo"] = "bar",
			["baz"] = "bar",
		})

		local destructions = 0

		local computedPair = Eager(ForKeys(state, function(use, key)
			return key .. "biz"
		end, function(key)
			destructions += 1
		end))

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

	it("should throw if there is a key collision", function()
		expect(function()
			local state = Value({
				["foo"] = "bar",
				["baz"] = "bar",
			})

			local computed = ForKeys(state, function(use)
				return "foo"
			end)
			peek(computed)
		end).to.throw("forKeysKeyCollision")

		local state = Value({
			["foo"] = "bar",
		})

		local computed = ForKeys(state, function(use)
			return "foo"
		end)

		expect(function()
			state:set({
				["foo"] = "bar",
				["baz"] = "bar",
			})
			peek(computed)
		end).to.throw("forKeysKeyCollision")
	end)

	it("should call the destructor with meta data", function()
		local state = Value({
			["foo"] = "bar",
		})

		local destructions = 0

		local computedKey = Eager(ForKeys(state, function(use, key)
			local newKey = key .. "biz"
			return newKey, newKey
		end, function(key, meta)
			expect(meta).to.equal(key)
			destructions += 1
		end))

		state:set({
			["baz"] = "bar",
		})

		-- this verifies that the meta expectation passed
		expect(destructions).to.equal(1)

		state:set({})

		-- this verifies that the meta expectation passed
		expect(destructions).to.equal(2)
	end)

	it("should only destruct an output key when it has no associated input key", function()
		local map = {
			["foo"] = "fiz",
			["bar"] = "fiz",
			["baz"] = "fuzz",
		}

		local state = Value({
			["foo"] = true,
		})

		local destructions = 0

		local computedKey = Eager(ForKeys(state, function(use, key)
			return map[key]
		end, function()
			destructions += 1
		end))

		state:set({
			["bar"] = true,
		})

		expect(destructions).to.equal(0)

		state:set({
			["foo"] = true,
			["bar"] = true,
			["baz"] = true,
		})

		expect(destructions).to.equal(0)

		state:set({
			["baz"] = true,
		})

		expect(destructions).to.equal(1)
	end)

	it("should recalculate its value in response to State objects", function()
		local baseMap = Value({
			["foo"] = "baz",
		})
		local barMap = ForKeys(baseMap, function(use, key)
			return key .. "bar"
		end)

		expect(peek(barMap)["foobar"]).to.be.ok()

		baseMap:set({
			["baz"] = "foo",
		})

		expect(peek(barMap)["bazbar"]).to.be.ok()
	end)

	it("should recalculate its value in response to ForKeys objects", function()
		local baseMap = Value({
			["foo"] = "baz",
		})
		local barMap = ForKeys(baseMap, function(use, key)
			return key .. "bar"
		end)
		local bizMap = ForKeys(barMap, function(use, key)
			return key .. "biz"
		end)

		expect(peek(barMap)["foobar"]).to.be.ok()
		expect(peek(bizMap)["foobarbiz"]).to.be.ok()

		baseMap:set({
			["fiz"] = "foo",
			["baz"] = "foo",
		})

		expect(peek(barMap)["fizbar"]).to.be.ok()
		expect(peek(bizMap)["fizbarbiz"]).to.be.ok()
		expect(peek(barMap)["bazbar"]).to.be.ok()
		expect(peek(bizMap)["bazbarbiz"]).to.be.ok()
	end)

	itSKIP("should not corrupt dependencies after an error", function()
		-- needs rewrite
	end)

	it("should garbage-collect unused objects", function()
		local state = Value({
			["foo"] = "bar",
		})

		local counter = 0

		do
			local computedKeys = ForKeys(state, function(use, key)
				counter += 1
				return key
			end)
			peek(computedKeys)
		end

		waitForGC()

		state:set({
			["bar"] = "baz",
		})

		expect(counter).to.equal(1)
	end)

	it("should not garbage-collect objects in use", function()
		local state = Value({
			["foo"] = "bar",
		})
		local computed2

		local counter = 0

		do
			local computed = ForKeys(state, function(use, key)
				counter += 1
				return key
			end)

			computed2 = ForKeys(computed, function(use, key)
				return key
			end)
		end

		waitForGC()
		state:set({
			["bar"] = "baz",
		})

		peek(computed2)

		expect(counter).to.equal(1)
	end)
end
