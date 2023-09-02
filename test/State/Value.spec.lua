local Package = game:GetService("ReplicatedStorage").Fusion
local Value = require(Package.State.Value)
local ForValues = require(Package.State.ForValues)
local peek = require(Package.State.peek)

return function()
	it("should construct a Value object", function()
		local value = Value()

		expect(value).to.be.a("table")
		expect(value.type).to.equal("State")
		expect(value.kind).to.equal("Value")
	end)

	it("should be able to store arbitrary values", function()
		local value = Value(0)
		expect(peek(value)).to.equal(0)

		value:set(10)
		expect(peek(value)).to.equal(10)

		value:set(Value)
		expect(peek(value)).to.equal(Value)
	end)

	it("should garbage-collect unused objects", function()
		local value = setmetatable({ { 2 } }, { __mode = "kv" })
		Value(value[1])

		expect(value[1]).to.equal(nil)
	end)

	it("should not garbage-collect objects in use", function()
		local value = setmetatable({ { 2 } }, { __mode = "kv" })
		local transformed = ForValues(Value(value[1]), function(innerValue)
			return innerValue[1] + 1
		end)

		expect(value[1]).never.to.equal(nil)
		expect(peek(transformed)[1]).to.equal(3)
	end)
end
