local Package = game:GetService("ReplicatedStorage").Fusion
local Eager = require(Package.State.Eager)
local Value = require(Package.State.Value)
local peek = require(Package.State.peek)

local waitForGC = require(script.Parent.Parent.Utility.waitForGC)

return function()
	it("should construct a Eager object", function()
		local eager = Eager(function(use) end)

		expect(eager).to.be.a("table")
		expect(eager.type).to.equal("State")
		expect(eager.kind).to.equal("Eager")
	end)

	it("should calculate and retrieve its value", function()
		local eager = Eager(function(use)
			return "foo"
		end)

		expect(peek(eager)).to.equal("foo")
	end)

	it("should recalculate its value in response to State objects", function()
		local currentNumber = Value(2)
		local doubled = Eager(function(use)
			return use(currentNumber) * 2
		end)

		expect(peek(doubled)).to.equal(4)

		currentNumber:set(4)
		expect(peek(doubled)).to.equal(8)
	end)

	it("should recalculate its value in response to Eager objects", function()
		local currentNumber = Value(2)
		local doubled = Eager(function(use)
			return use(currentNumber) * 2
		end)
		local tripled = Eager(function(use)
			return use(doubled) * 1.5
		end)

		expect(peek(tripled)).to.equal(6)

		currentNumber:set(4)
		expect(peek(tripled)).to.equal(12)
	end)

	it("should not corrupt dependencies after an error", function()
		local state = Value(1)
		local simulateError = false
		local eager = Eager(function(use)
			if simulateError then
				-- in a naive implementation, this would corrupt dependencies as
				-- use(state) hasn't been captured yet, preventing future
				-- reactive updates from taking place
				-- to avoid this, dependencies captured when a callback errors
				-- have to be discarded
				error("This is an intentional error from a unit test")
			end

			return use(state)
		end)

		expect(peek(eager)).to.equal(1)

		simulateError = true
		state:set(5) -- update the eager to invoke the error

		simulateError = false
		state:set(10) -- if dependencies are corrupt, the eager won't update

		expect(peek(eager)).to.equal(10)
	end)

	it("should garbage-collect unused objects", function()
		local state = Value(2)

		local counter = 0

		do
			local eager = Eager(function(use)
				counter += 1
				return use(state)
			end)
		end

		waitForGC()
		state:set(5)

		expect(counter).to.equal(1)
	end)

	it("should not garbage-collect objects in use", function()
		local state = Value(2)
		local eager2

		local counter = 0

		do
			local eager = Eager(function(use)
				counter += 1
				return use(state)
			end)

			eager2 = Eager(function(use)
				return use(eager)
			end)
		end

		waitForGC()
		state:set(5)

		expect(counter).to.equal(2)
	end)

	it("should call destructors when old values are replaced", function()
		local didRun = false
		local function destructor(x)
			if x == "old" then
				didRun = true
			end
		end

		local value = Value("old")
		local eager = Eager(function(use)
			return use(value)
		end, destructor)
		value:set("new")

		expect(didRun).to.equal(true)
	end)
end
