--!strict

local tiniest = require("../../lib/tiniest_for_roblox")

local isSimilar = require("../../../src/Utility/isSimilar")

return function(tiniest: tiniest.Configured): ()
	local describe = tiniest.describe
	local test = tiniest.test
	local expect = tiniest.expect

	local function resultOf(a, b)
		local forward = isSimilar(a, b)
		local reverse = isSimilar(b, a)
		expect(forward).is(reverse)
		return forward
	end

	test("identical", function()
		expect(resultOf(123, 123)).is(true)
	end)

	test("different", function()
		expect(resultOf(123, 321)).is(false)
	end)

	test("nan", function()
		expect(resultOf(0 / 0, math.huge / math.huge)).is(true)
	end)

	test("mutable table", function()
		local self = { foo = "bar" }
		expect(resultOf(self, self)).is(false)
	end)

	test("frozen table", function()
		local self = table.freeze { foo = "bar" }
		local other = table.freeze { foo = "bar" }
		expect(resultOf(self, self)).is(true)
		expect(resultOf(self, other)).is(false)
	end)

	describe("userdata", function()
		test("no metatable", function()
			local self = newproxy(false)
			local other = newproxy(false)
			expect(resultOf(self, self)).is(true)
			expect(resultOf(self, other)).is(false)
		end)

		test("default metatable", function()
			local self = newproxy(true)
			local other = newproxy(true)
			expect(resultOf(self, self)).is(true)
			expect(resultOf(self, other)).is(false)
		end)
	end)
	
	describe("__eq", function()

		local function runEqTest(constructor: any, ...)
			local output

			local original, sameEq, diffEq = constructor(...), constructor(...), constructor(...)
			local original_mt = getmetatable(original)
			local sameEq_mt = getmetatable(sameEq)
			local diffEq_mt = getmetatable(diffEq)
			original_mt.__eq = function()
				return output
			end
			sameEq_mt.__eq = original_mt.__eq
			diffEq_mt.__eq = function()
				return output
			end
			original_mt.__metatable = "This metatable is locked"
			sameEq_mt.__metatable = "This metatable is locked"
			diffEq_mt.__metatable = "This metatable is locked"

			expect(resultOf(original, diffEq)).is(false)
			expect(resultOf(sameEq, diffEq)).is(false)
			output = true
			expect(resultOf(original, original)).is(output)
			expect(resultOf(original, sameEq)).is(output)
			expect(resultOf(sameEq, diffEq)).is(false)
			output = false
			expect(resultOf(original, original)).is(output)
			expect(resultOf(original, sameEq)).is(output)
			expect(resultOf(sameEq, diffEq)).is(false)
		end

		test("userdata", function()
			runEqTest(newproxy, true)
		end)
		
		test("mutable tables", function()
			runEqTest(function()
				return setmetatable({}, {})
			end)
		end)

		test("frozen tables", function()
			runEqTest(function()
				return table.freeze(setmetatable({}, {}))
			end)
		end)
	end)

	describe("roblox", function()
		test("vector2", function()
			local a, b = Vector2.new(10, 10), Vector2.new(10, 10)
			expect(resultOf(a, a)).is(true)
			expect(resultOf(a, b)).is(true)

			local c = Vector2.new(20, 20)
			expect(resultOf(a, c)).is(false)
		end)

		test("vector3", function()
			local a, b = Vector3.new(10, 10, 10), Vector3.new(10, 10, 10)
			expect(resultOf(a, a)).is(true)
			expect(resultOf(a, b)).is(true)
			expect(resultOf(a, b)).is(true)

			local c = Vector3.new(20, 20, 20)
			expect(resultOf(a, c)).is(false)
		end)

		test("cframe", function()
			local a, b = CFrame.new(10, 10, 10), CFrame.new(10, 10, 10)
			expect(resultOf(a, a)).is(true)
			expect(resultOf(a, b)).is(true)
			
			local c = CFrame.new(20, 20, 20)
			expect(resultOf(a, c)).is(false)
		end)

		describe("nan", function()
			test("vector2", function()
				local a, b = Vector2.new(0 / 0, 0 / 0), Vector2.new(math.huge / math.huge, math.huge / math.huge)
				expect(resultOf(a, a)).is(true)
				expect(resultOf(a, b)).is(true)
	
				local c = Vector2.new(20, 20)
				expect(resultOf(a, c)).is(false)
			end)
	
			test("vector3", function()
				local a, b = Vector3.new(0 / 0, 0 / 0, 0 / 0), Vector3.new(math.huge / math.huge, math.huge / math.huge, math.huge / math.huge)
				expect(resultOf(a, a)).is(true)
				expect(resultOf(a, b)).is(true)
				expect(resultOf(a, b)).is(true)
	
				local c = Vector3.new(20, 20, 20)
				expect(resultOf(a, c)).is(false)
			end)
	
			test("cframe", function()
				local a, b = CFrame.new(0 / 0, 0 / 0, 0 / 0), CFrame.new(math.huge / math.huge, math.huge / math.huge, math.huge / math.huge)
				expect(resultOf(a, a)).is(true)
				expect(resultOf(a, b)).is(true)
				
				local c = CFrame.new(20, 20, 20)
				expect(resultOf(a, c)).is(false)
			end)
		end)
	end)
end