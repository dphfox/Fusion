local RunService = game:GetService("RunService")

local Package = game:GetService("ReplicatedStorage").Fusion
local ForValues = require(Package.State.ForValues)
local Value = require(Package.State.Value)

local waitForGC = require(script.Parent.Parent.Utility.waitForGC)

return function()
	it("should construct a ForValues object", function()
		local computed = ForValues({}, function() end)

		expect(computed).to.be.a("table")
		expect(computed.type).to.equal("State")
		expect(computed.kind).to.equal("ForValues")
	end)

	it("should calculate and retrieve its value", function()
		local computed = ForValues({ 1 }, function(value)
			return value
		end)

		local state = computed:get()

		expect(state[1]).to.be.ok()
		expect(state[1]).to.equal(1)
	end)

	it("should not recalculate its VO in response to a changed VI", function()
		local state = Value({
			[1] = "foo",
		})

		local calculations = 0

		local computed = ForValues(state, function(value)
			calculations += 1
			return value
		end)

		expect(calculations).to.equal(1)

		state:set({
			[1] = "bar",
			[2] = "foo",
		})

		expect(calculations).to.equal(2)
	end)

	it("should only call the processor the first time an output value is added", function()
		local state = Value({
			[1] = "foo",
		})

		local processorCalls = 0

		local computed = ForValues(state, function(value)
			processorCalls += 1

			return value .. "biz"
		end)

		expect(processorCalls).to.equal(1)

		state:set({
			[1] = "bar",
		})

		expect(processorCalls).to.equal(2)

		state:set({
			[2] = "bar",
			[3] = "bar",
		})

		expect(processorCalls).to.equal(3)

		state:set({
			[1] = "bar",
			[2] = "bar",
		})

		expect(processorCalls).to.equal(3)

		state:set({})

		expect(processorCalls).to.equal(3)

		state:set({
			[1] = "bar",
			[2] = "foo",
		})

		expect(processorCalls).to.equal(5)
	end)

	it("should only call the destructor when a constant value gets removed from all indices", function()
		local state = Value({
			[1] = "foo",
		})

		local destructions = 0

		local computed = ForValues(state, function(value)
			return value .. "biz"
		end, function(key)
			destructions += 1
		end)

		state:set({
			[1] = "bar",
		})

		expect(destructions).to.equal(1)

		state:set({
			[2] = "bar",
			[3] = "bar",
		})

		expect(destructions).to.equal(1)

		state:set({
			[1] = "bar",
			[2] = "bar",
			[3] = "foo",
			[4] = "foo",
		})

		expect(destructions).to.equal(1)

		state:set({
			[1] = "foo",
		})

		expect(destructions).to.equal(4)

		state:set({})

		expect(destructions).to.equal(5)
	end)

	it("should only call the destructor when a non-constant value gets removed from all indices", function()
		local mem1 = Instance.new("Folder")
		local mem2 = Instance.new("Folder")
		local mem3 = Instance.new("Folder")

		local state = Value({
			[1] = mem1,
		})

		local destructions = 0

		local computed = ForValues(state, function(value)
			local obj = Instance.new("Folder")
			obj.Parent = value

			return obj
		end, function(value)
			destructions += 1
			value:Destroy()
		end)

		state:set({
			[1] = mem2,
		})

		expect(destructions).to.equal(1)

		state:set({
			[2] = mem3,
			[3] = mem2,
		})

		expect(destructions).to.equal(1)

		state:set({
			[1] = mem2,
			[2] = mem3,
		})

		expect(destructions).to.equal(1)

		state:set({})

		expect(destructions).to.equal(3)
	end)

	it("should call the destructor with meta data", function()
		local state = Value({
			[1] = "foo",
		})

		local destructions = 0

		local computed = ForValues(state, function(value)
			local newValue = value .. "biz"
			return newValue, newValue
		end, function(value, meta)
			expect(meta).to.equal(value)
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

	it("should not make any value changes or processor/destructor calls when only the input key changes", function()
		local state = Value({
			["foo"] = "bar",
			["bar"] = "baz",
			["biz"] = "buzz",
		})

		local processorCalls = 0
		local destructorCalls = 0

		local computed = ForValues(state, function(value)
			processorCalls += 1
			return value
		end, function(value)
			destructorCalls += 1
		end)

		expect(processorCalls).to.equal(3)
		expect(destructorCalls).to.equal(0)

		state:set({
			[1] = "buzz",
			["bar"] = "bar",
			["fiz"] = "baz",
		})

		expect(processorCalls).to.equal(3)
		expect(destructorCalls).to.equal(0)

		state:set({
			[1] = "bar",
			["bar"] = "bar",
			["fiz"] = "bar",
		})

		expect(processorCalls).to.equal(5)
		expect(destructorCalls).to.equal(2)

		state:set({
			[2] = "bar",
			[3] = "baz",
		})

		expect(processorCalls).to.equal(6)
		expect(destructorCalls).to.equal(4)

		state:set({})

		expect(processorCalls).to.equal(6)
		expect(destructorCalls).to.equal(6)
	end)

	it("should recalculate its value in response to State objects", function()
		local state = Value({
			[1] = "baz",
		})
		local barMap = ForValues(state, function(value)
			return value .. "bar"
		end)

		expect(barMap:get()[1]).to.equal("bazbar")

		state:set({
			[1] = "bar",
		})

		expect(barMap:get()[1]).to.equal("barbar")
	end)

	it("should recalculate its value in response to ForValues objects", function()
		local state = Value({
			[1] = 1,
		})
		local doubled = ForValues(state, function(value)
			return value * 2
		end)
		local tripled = ForValues(doubled, function(value)
			return value * 2
		end)

		expect(doubled:get()[1]).to.equal(2)
		expect(tripled:get()[1]).to.equal(4)

		state:set({
			[1] = 2,
			[2] = 3,
		})

		expect(doubled:get()[1]).to.equal(4)
		expect(tripled:get()[1]).to.equal(8)
		expect(doubled:get()[2]).to.equal(6)
		expect(tripled:get()[2]).to.equal(12)
	end)

	it("should recalculate its value in response to a dependency change", function()
		local state = Value({ 
			[1] = 1,
			[5] = 5,
			[10] = 10,
		 })
		local increment = Value(1)

		local computed = ForValues(state, function(value)
			return value + increment:get()
		end)

		expect(computed:get()[1]).to.equal(2)
		expect(computed:get()[5]).to.equal(6)
		expect(computed:get()[10]).to.equal(11)

		increment:set(2)

		task.wait()
		task.wait()

		expect(computed:get()[1]).to.equal(3)
		expect(computed:get()[5]).to.equal(7)
		expect(computed:get()[10]).to.equal(12)

		increment:set(1)

		task.wait()
		task.wait()

		expect(computed:get()[1]).to.equal(2)
		expect(computed:get()[5]).to.equal(6)
		expect(computed:get()[10]).to.equal(11)

		state:set({
			[1] = 10,
			[5] = 1,
			[10] = 5,
		})

		expect(computed:get()[1]).to.equal(11)
		expect(computed:get()[5]).to.equal(2)
		expect(computed:get()[10]).to.equal(6)
	end)

	it("should not corrupt dependencies after an error", function()
		local state = Value({
			[1] = 1,
		})
		local simulateError = false
		local computed = ForValues(state, function(value)
			if simulateError then
				-- in a naive implementation, this would corrupt dependencies as
				-- state:get() hasn't been captured yet, preventing future
				-- reactive updates from taking place
				-- to avoid this, dependencies captured when a callback errors
				-- have to be discarded
				error("This is an intentional error from a unit test")
			end

			return value
		end)

		expect(computed:get()[1]).to.equal(1)

		simulateError = true
		state:set({
			[1] = 5,
		}) -- update the computed to invoke the error

		simulateError = false
		state:set({
			[1] = 10,
		}) -- if dependencies are corrupt, the computed won't update

		expect(computed:get()[1]).to.equal(10)
	end)

	it("should garbage-collect unused objects", function()
		local state = Value({
			[1] = "bar",
		})

		local counter = 0

		do
			local computedKeys = ForValues(state, function(value)
				counter += 1
				return value
			end)
		end

		waitForGC()

		state:set({
			[1] = "biz",
		})

		expect(counter).to.equal(1)
	end)

	it("should not garbage-collect objects in use", function()
		local state = Value({
			[1] = 1,
		})
		local computed2

		local counter = 0

		do
			local computed = ForValues(state, function(value)
				counter += 1
				return value
			end)

			computed2 = ForValues(computed, function(value)
				return value
			end)
		end

		waitForGC()
		state:set({
			[1] = 2,
		})

		expect(counter).to.equal(2)
	end)
end
