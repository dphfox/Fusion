local RunService = game:GetService("RunService")

local Package = game:GetService("ReplicatedStorage").Fusion
local ForValues = require(Package.State.ForValues)
local Value = require(Package.State.Value)
local peek = require(Package.State.peek)

return function()
	-- it("should construct a ForValues object", function()
	-- 	local forKeys = ForValues({}, function(use) end)

	-- 	expect(forKeys).to.be.a("table")
	-- 	expect(forKeys.type).to.equal("State")
	-- 	expect(forKeys.kind).to.equal("ForValues")
	-- end)

	-- it("should calculate and retrieve its value", function()
	-- 	local computed = ForValues({ 1 }, function(use, value)
	-- 		return value
	-- 	end)

	-- 	local state = peek(computed)

	-- 	expect(state[1]).to.be.ok()
	-- 	expect(state[1]).to.equal(1)
	-- end)

	-- it("should not recalculate its VO in response to a changed VI", function()
	-- 	local state = Value({
	-- 		[1] = "foo",
	-- 	})

	-- 	local calculations = 0

	-- 	local computed = ForValues(state, function(use, value)
	-- 		calculations += 1
	-- 		return value
	-- 	end)

	-- 	expect(calculations).to.equal(1)

	-- 	state:set({
	-- 		[1] = "bar",
	-- 		[2] = "foo",
	-- 	})

	-- 	expect(calculations).to.equal(2)
	-- end)

	-- it("should only call the processor the first time a constant output value is added", function()
	-- 	local state = Value({
	-- 		[1] = "foo",
	-- 	})

	-- 	local processorCalls = 0

	-- 	local computed = ForValues(state, function(use, value)
	-- 		processorCalls += 1

	-- 		return value .. "biz"
	-- 	end)

	-- 	expect(processorCalls).to.equal(1)

	-- 	state:set({
	-- 		[1] = "bar",
	-- 	})

	-- 	expect(processorCalls).to.equal(2)

	-- 	state:set({
	-- 		[2] = "bar",
	-- 		[3] = "bar",
	-- 	})

	-- 	expect(processorCalls).to.equal(2)

	-- 	state:set({
	-- 		[1] = "bar",
	-- 		[2] = "bar",
	-- 	})

	-- 	expect(processorCalls).to.equal(2)

	-- 	state:set({})

	-- 	expect(processorCalls).to.equal(2)

	-- 	state:set({
	-- 		[1] = "bar",
	-- 		[2] = "foo",
	-- 	})

	-- 	expect(processorCalls).to.equal(4)
	-- end)

	-- it("should only call the destructor when a constant value gets removed from all indices", function()
	-- 	local state = Value({
	-- 		[1] = "foo",
	-- 	})

	-- 	local destructions = 0

	-- 	local computed = ForValues(state, function(use, value)
	-- 		return value .. "biz"
	-- 	end, function(key)
	-- 		destructions += 1
	-- 	end)

	-- 	state:set({
	-- 		[1] = "bar",
	-- 	})

	-- 	expect(destructions).to.equal(1)

	-- 	state:set({
	-- 		[2] = "bar",
	-- 		[3] = "bar",
	-- 	})

	-- 	expect(destructions).to.equal(1)

	-- 	state:set({
	-- 		[1] = "bar",
	-- 		[2] = "bar",
	-- 	})

	-- 	expect(destructions).to.equal(1)

	-- 	state:set({})

	-- 	expect(destructions).to.equal(2)
	-- end)

	-- it("should only call the destructor when a non-constant value gets removed from all indices", function()
	-- 	local mem1 = Instance.new("Folder")
	-- 	local mem2 = Instance.new("Folder")
	-- 	local mem3 = Instance.new("Folder")

	-- 	local state = Value({
	-- 		[1] = mem1,
	-- 	})

	-- 	local destructions = 0

	-- 	local computed = ForValues(state, function(use, value)
	-- 		local obj = Instance.new("Folder")
	-- 		obj.Parent = value

	-- 		return obj
	-- 	end, function(value)
	-- 		destructions += 1
	-- 		value:Destroy()
	-- 	end)

	-- 	state:set({
	-- 		[1] = mem2,
	-- 	})

	-- 	expect(destructions).to.equal(1)

	-- 	state:set({
	-- 		[2] = mem3,
	-- 		[3] = mem2,
	-- 	})

	-- 	expect(destructions).to.equal(1)

	-- 	state:set({
	-- 		[1] = mem2,
	-- 		[2] = mem3,
	-- 	})

	-- 	expect(destructions).to.equal(1)

	-- 	state:set({})

	-- 	expect(destructions).to.equal(3)
	-- end)

	-- it("should call the destructor with meta data", function()
	-- 	local state = Value({
	-- 		[1] = "foo",
	-- 	})

	-- 	local destructions = 0

	-- 	local computed = ForValues(state, function(use, value)
	-- 		local newValue = value .. "biz"
	-- 		return newValue, newValue
	-- 	end, function(value, meta)
	-- 		expect(meta).to.equal(value)
	-- 		destructions += 1
	-- 	end)

	-- 	state:set({
	-- 		["baz"] = "bar",
	-- 	})

	-- 	-- this verifies that the meta expectation passed
	-- 	expect(destructions).to.equal(1)

	-- 	state:set({})

	-- 	-- this verifies that the meta expectation passed
	-- 	expect(destructions).to.equal(2)
	-- end)

	-- it("should not make any value changes or processor/destructor calls when only the input key changes", function()
	-- 	local state = Value({
	-- 		["foo"] = "bar",
	-- 		["bar"] = "baz",
	-- 		["biz"] = "buzz",
	-- 	})

	-- 	local processorCalls = 0
	-- 	local destructorCalls = 0

	-- 	local computed = ForValues(state, function(use, value)
	-- 		processorCalls += 1
	-- 		return value
	-- 	end, function(value)
	-- 		destructorCalls += 1
	-- 	end)

	-- 	expect(processorCalls).to.equal(3)
	-- 	expect(destructorCalls).to.equal(0)

	-- 	state:set({
	-- 		[1] = "buzz",
	-- 		["bar"] = "bar",
	-- 		["fiz"] = "baz",
	-- 	})

	-- 	expect(processorCalls).to.equal(3)
	-- 	expect(destructorCalls).to.equal(0)

	-- 	state:set({
	-- 		[1] = "bar",
	-- 		["bar"] = "bar",
	-- 		["fiz"] = "bar",
	-- 	})

	-- 	expect(processorCalls).to.equal(3)
	-- 	expect(destructorCalls).to.equal(2)

	-- 	state:set({
	-- 		[2] = "bar",
	-- 		[3] = "baz",
	-- 	})

	-- 	expect(processorCalls).to.equal(4)
	-- 	expect(destructorCalls).to.equal(2)

	-- 	state:set({})

	-- 	expect(processorCalls).to.equal(4)
	-- 	expect(destructorCalls).to.equal(4)
	-- end)

	-- it("should recalculate its value in response to State objects", function()
	-- 	local state = Value({
	-- 		[1] = "baz",
	-- 	})
	-- 	local barMap = ForValues(state, function(use, value)
	-- 		return value .. "bar"
	-- 	end)

	-- 	expect(peek(barMap)[1]).to.equal("bazbar")

	-- 	state:set({
	-- 		[1] = "bar",
	-- 	})

	-- 	expect(peek(barMap)[1]).to.equal("barbar")
	-- end)

	-- it("should recalculate its value in response to ForValues objects", function()
	-- 	local state = Value({
	-- 		[1] = 1,
	-- 	})
	-- 	local doubled = ForValues(state, function(use, value)
	-- 		return value * 2
	-- 	end)
	-- 	local tripled = ForValues(doubled, function(use, value)
	-- 		return value * 2
	-- 	end)

	-- 	expect(peek(doubled)[1]).to.equal(2)
	-- 	expect(peek(tripled)[1]).to.equal(4)

	-- 	state:set({
	-- 		[1] = 2,
	-- 		[2] = 3,
	-- 	})

	-- 	expect(peek(doubled)[1]).to.equal(4)
	-- 	expect(peek(tripled)[1]).to.equal(8)
	-- 	expect(peek(doubled)[2]).to.equal(6)
	-- 	expect(peek(tripled)[2]).to.equal(12)
	-- end)

	-- itSKIP("should not corrupt dependencies after an error", function()
	-- 	-- needs rewrite
	-- end)

	-- it("should garbage-collect unused objects", function()
	-- 	local state = Value({
	-- 		[1] = "bar",
	-- 	})

	-- 	local counter = 0

	-- 	do
	-- 		local computedKeys = ForValues(state, function(use, value)
	-- 			counter += 1
	-- 			return value
	-- 		end)
	-- 	end

	-- 	state:set({
	-- 		[1] = "biz",
	-- 	})

	-- 	expect(counter).to.equal(1)
	-- end)

	-- it("should not garbage-collect objects in use", function()
	-- 	local state = Value({
	-- 		[1] = 1,
	-- 	})
	-- 	local computed2

	-- 	local counter = 0

	-- 	do
	-- 		local computed = ForValues(state, function(use, value)
	-- 			counter += 1
	-- 			return value
	-- 		end)

	-- 		computed2 = ForValues(computed, function(use, value)
	-- 			return value
	-- 		end)
	-- 	end
		
	-- 	state:set({
	-- 		[1] = 2,
	-- 	})

	-- 	expect(counter).to.equal(2)
	-- end)
end
