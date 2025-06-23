--!strict

local tiniest = require("../../lib/tiniest_for_roblox")

local Fusion = require("../../../src")

return function(tiniest: tiniest.Configured): ()
	local describe = tiniest.describe
	local test = tiniest.test
	local expect = tiniest.expect

	describe("regression", function()
		test("eager update that causes sub-update shouldn't block other eager updates", function()
			local scope = Fusion:scoped()
			local count = 0
			local unrelatedValue = scope:Value(count)
			local trigger = scope:Value(false)
			scope:Observer(trigger):onChange(function()
				count += 1
				unrelatedValue:set(count)
			end)
			local numFires = 0
			scope:Observer(trigger):onChange(function()
				numFires += 1
			end)
			trigger:set(true)
			expect(numFires).is(1)
			trigger:set(false)
			expect(numFires).is(2)
			trigger:set(true)
			expect(numFires).is(3)
			scope:doCleanup()
		end)
	end)
end