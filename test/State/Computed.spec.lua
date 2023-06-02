local Package = game:GetService("ReplicatedStorage").Fusion
local Computed = require(Package.State.Computed)
local Value = require(Package.State.Value)
local peek = require(Package.State.peek)

local waitForGC = require(script.Parent.Parent.Utility.waitForGC)

return function()
	it("should construct a Computed object", function()
		local computed = Computed(function(use) end)

		expect(computed).to.be.a("table")
		expect(computed.type).to.equal("State")
		expect(computed.kind).to.equal("Computed")
	end)

	it("should calculate and retrieve its value", function()
		local computed = Computed(function(use)
			return "foo"
		end)

		expect(peek(computed)).to.equal("foo")
	end)

	it("should recalculate its value in response to State objects", function()
		local currentNumber = Value(2)
		local doubled = Computed(function(use)
			return use(currentNumber) * 2
		end)

		expect(peek(doubled)).to.equal(4)

		currentNumber:set(4)
		expect(peek(doubled)).to.equal(8)
	end)

	it("should recalculate its value in response to Computed objects", function()
		local currentNumber = Value(2)
		local doubled = Computed(function(use)
			return use(currentNumber) * 2
		end)
		local tripled = Computed(function(use)
			return use(doubled) * 1.5
		end)

		expect(peek(tripled)).to.equal(6)

		currentNumber:set(4)
		expect(peek(tripled)).to.equal(12)
	end)

	it("should never calculate its value if it has no dependents", function()
		local state = Value(2)
		local computed = Computed(function(use)
			return use(state)
		end)

		expect(computed._value).never.to.be.ok()

		state:set(4)

		expect(computed._value).never.to.be.ok()
	end)

	it("should not corrupt dependencies after an error", function()
		local state = Value(1)
		local simulateError = false
		local computed = Computed(function(use)
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
		-- fake dependent to allow for updating
		computed.dependentSet[{
			update = function() end,
			dependencySet = {}
		}] = true 

		expect(peek(computed)).to.equal(1)

		simulateError = true
		state:set(5) -- update the computed to invoke the error

		simulateError = false
		state:set(10) -- if dependencies are corrupt, the computed won't update

		expect(peek(computed)).to.equal(10)
	end)

	itFIXME("should garbage-collect unused objects", function()
		--FIXME: This test doesn't work with lazy state calculation.

		local state = Value(2)
		local counter = 0

		do
			local computed = Computed(function(use)
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
		local computed2

		local counter = 0

		do
			local computed = Computed(function(use)
				counter += 1
				return use(state)
			end)
			computed2 = Computed(function(use)
				return use(computed)
			end)
		end

		waitForGC()
		state:set(5)

		peek(computed2) -- force update
		expect(counter).to.equal(1)
	end)

	it("should call destructors when old values are replaced", function()
		local didRun = false
		local function destructor(x)
			if x == "old" then
				didRun = true
			end
		end

		local value = Value("old")
		local computed = Computed(function(use)
			return use(value)
		end, destructor)

		peek(computed) -- force update

		value:set("new")

		peek(computed) -- force update

		expect(didRun).to.equal(true)
	end)
end
