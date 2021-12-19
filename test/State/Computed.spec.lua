local RunService = game:GetService("RunService")

local Package = game:GetService("ReplicatedStorage").Fusion
local Computed = require(Package.State.Computed)
local Value = require(Package.State.Value)

local function waitForGC()
	local ref = setmetatable({{}}, {__mode = "kv"})

	repeat
		RunService.Heartbeat:Wait()
	until ref[1] == nil
end

return function()
	it("should construct a Computed object", function()
		local computed = Computed(function()
		end)

		expect(computed).to.be.a("table")
		expect(computed.type).to.equal("State")
		expect(computed.kind).to.equal("Computed")
	end)

	it("should calculate and retrieve its value", function()
		local computed = Computed(function()
			return "foo"
		end)

		expect(computed:get()).to.equal("foo")
	end)

	it("should recalculate its value in response to State objects", function()
		local currentNumber = Value(2)
		local doubled = Computed(function()
			return currentNumber:get() * 2
		end)

		expect(doubled:get()).to.equal(4)

		currentNumber:set(4)
		expect(doubled:get()).to.equal(8)
	end)

	it("should recalculate its value in response to Computed objects", function()
		local currentNumber = Value(2)
		local doubled = Computed(function()
			return currentNumber:get() * 2
		end)
		local tripled = Computed(function()
			return doubled:get() * 1.5
		end)

		expect(tripled:get()).to.equal(6)

		currentNumber:set(4)
		expect(tripled:get()).to.equal(12)
	end)

	it("should not corrupt dependencies after an error", function()
		local state = Value(1)
		local simulateError = false
		local computed = Computed(function()
			if simulateError then
				-- in a naive implementation, this would corrupt dependencies as
				-- state:get() hasn't been captured yet, preventing future
				-- reactive updates from taking place
				-- to avoid this, dependencies captured when a callback errors
				-- have to be discarded
				error("This is an intentional error from a unit test")
			end

			return state:get()
		end)

		expect(computed:get()).to.equal(1)

		simulateError = true
		state:set(5) -- update the computed to invoke the error

		simulateError = false
		state:set(10) -- if dependencies are corrupt, the computed won't update

		expect(computed:get()).to.equal(10)
	end)

	it("should garbage-collect unused objects", function()
		local state = Value(2)

		local counter = 0

		do
			local computed = Computed(function()
				counter += 1
				return state:get()
			end)
		end

		waitForGC()
		state:set(5)

		expect(counter).to.equal(1)
	end)

	it("should not garbage-collect objects in use", function()
		local state = Value(2)
		local computed2

		local counter = 0

		do
			local computed = Computed(function()
				counter += 1
				return state:get()
			end)

			computed2 = Computed(function()
				return computed:get()
			end)
		end

		waitForGC()
		state:set(5)

		expect(counter).to.equal(2)
	end)

	it("should not allow the callback to yield", function()
		local state = Value("foo")

		expect(function()
			Computed(function()
				task.wait()
				return state:get()
			end)
		end).to.throw("computedCannotYield")

		local counter = 0
		local computedDelayed = Computed(function()
			if counter > 0 then
				task.wait()
			end

			counter = counter + 1

			return state:get()
		end)

		expect(function()
			state:set("bar")
		end).to.throw("computedCannotYield")
	end)
end
