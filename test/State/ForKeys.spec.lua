local RunService = game:GetService("RunService")

local Package = game:GetService("ReplicatedStorage").Fusion
local ForKeys = require(Package.State.ForKeys)
local Value = require(Package.State.Value)

local waitForGC = require(script.Parent.Parent.Utility.waitForGC)

return function()
	it("should construct a ForKeys object", function()
		local state = ForKeys({}, function() end)

		expect(state).to.be.a("table")
		expect(state.type).to.equal("State")
		expect(state.kind).to.equal("ForKeys")
	end)

	it("should calculate and retrieve its value", function()
		local state = ForKeys({ ["foo"] = true }, function(key)
			return key .. "baz"
		end)

		local value = state:get()

		expect(value["foobaz"]).to.be.ok()
		expect(value["foobaz"]).to.equal(true)
	end)

	it("should not recalculate its KO in response to an unchanged KI", function()
		local state = Value({
			["foo"] = "bar",
		})

		local calculations = 0

		local _computed = ForKeys(state, function(key)
			calculations += 1
			return key
		end)

		expect(calculations).to.equal(1)

		state:set({
			["foo"] = "biz",
			["baz"] = "bar",
		})

		expect(calculations).to.equal(2)
	end)

	it("should call the destructor when a key gets removed", function()
		local state = Value({
			["foo"] = "bar",
			["baz"] = "bar",
		})

		local destructions = 0

		local _computed = ForKeys(state, function(key)
			return key .. "biz"
		end, function()
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

	it("should throw if there is a key collision", function()
		expect(function()
			local state = Value({
				["foo"] = "bar",
				["baz"] = "bar",
			})

			local _computed = ForKeys(state, function()
				return "foo"
			end)
		end).to.throw("forKeysKeyCollision")

		local state = Value({
			["foo"] = "bar",
		})

		local _computed = ForKeys(state, function()
			return "foo"
		end)

		expect(function()
			state:set({
				["foo"] = "bar",
				["baz"] = "bar",
			})
		end).to.throw("forKeysKeyCollision")
	end)

	it("should call the destructor with meta data", function()
		local state = Value({
			["foo"] = "bar",
		})

		local destructions = 0

		local _computed = ForKeys(state, function(key)
			local newKey = key .. "biz"
			return newKey, newKey
		end, function(key, meta)
			expect(meta).to.equal(key)
			destructions += 1
		end)

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

		local _computed = ForKeys(state, function(key)
			return map[key]
		end, function()
			destructions += 1
		end)

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
		local state = Value({
			["foo"] = "baz",
		})
		local computedBar = ForKeys(state, function(key)
			return key .. "bar"
		end)

		expect(computedBar:get()["foobar"]).to.be.ok()

		state:set({
			["baz"] = "foo",
		})

		expect(computedBar:get()["bazbar"]).to.be.ok()
	end)

	it("should recalculate its value in response to ForKeys objects", function()
		local map = Value({
			["foo"] = "baz",
		})
		local computedBar = ForKeys(map, function(key)
			return key .. "bar"
		end)
		local computedBarBiz = ForKeys(computedBar, function(key)
			return key .. "biz"
		end)

		expect(computedBar:get()["foobar"]).to.be.ok()
		expect(computedBarBiz:get()["foobarbiz"]).to.be.ok()

		map:set({
			["fiz"] = "foo",
			["baz"] = "foo",
		})

		expect(computedBar:get()["fizbar"]).to.be.ok()
		expect(computedBarBiz:get()["fizbarbiz"]).to.be.ok()
		expect(computedBar:get()["bazbar"]).to.be.ok()
		expect(computedBarBiz:get()["bazbarbiz"]).to.be.ok()
	end)

	it("should recalculate its value in response to a dependency change", function()
		local state = Value({ 
			[1] = true,
			[5] = true,
			[10] = true,
		 })
		local increment = Value(1)

		local computed = ForKeys(state, function(key)
			return key + increment:get()
		end)

		expect(computed:get()[1]).never.to.be.ok()
		expect(computed:get()[5]).never.to.be.ok()
		expect(computed:get()[10]).never.to.be.ok()

		expect(computed:get()[2]).to.be.ok()
		expect(computed:get()[6]).to.be.ok()
		expect(computed:get()[11]).to.be.ok()

		increment:set(2)

		task.wait()
		task.wait()

		expect(computed:get()[2]).never.to.be.ok()
		expect(computed:get()[6]).never.to.be.ok()
		expect(computed:get()[11]).never.to.be.ok()

		expect(computed:get()[3]).to.be.ok()
		expect(computed:get()[7]).to.be.ok()
		expect(computed:get()[12]).to.be.ok()

		increment:set(1)

		task.wait()
		task.wait()

		expect(computed:get()[3]).never.to.be.ok()
		expect(computed:get()[7]).never.to.be.ok()
		expect(computed:get()[12]).never.to.be.ok()

		expect(computed:get()[2]).to.be.ok()
		expect(computed:get()[6]).to.be.ok()
		expect(computed:get()[11]).to.be.ok()
	end)

	it("should not corrupt dependencies after an error", function()
		local state = Value({
			["foo"] = "bar",
		})
		local simulateError = false
		local computed = ForKeys(state, function(key)
			if simulateError then
				-- in a naive implementation, this would corrupt dependencies as
				-- state:get() hasn't been captured yet, preventing future
				-- reactive updates from taking place
				-- to avoid this, dependencies captured when a callback errors
				-- have to be discarded
				error("This is an intentional error from a unit test")
			end

			return key
		end)

		expect(computed:get()["foo"]).to.be.ok()

		simulateError = true
		state:set({
			["bar"] = "baz",
		}) -- update the computed to invoke the error

		simulateError = false
		state:set({
			["bar"] = "fiz",
		}) -- if dependencies are corrupt, the computed won't update

		expect(computed:get()["bar"]).to.be.ok()
	end)

	it("should garbage-collect unused objects", function()
		local state = Value({
			["foo"] = "bar",
		})

		local counter = 0

		do
			local _computed = ForKeys(state, function(key)
				counter += 1
				return key
			end)
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
			local computed = ForKeys(state, function(key)
				counter += 1
				return key
			end)

			computed2 = ForKeys(computed, function(key)
				return key
			end)
		end

		waitForGC()
		state:set({
			["bar"] = "baz",
		})

		expect(counter).to.equal(2)
	end)
end
