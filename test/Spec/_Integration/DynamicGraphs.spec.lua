--!strict
--!nolint LocalUnused
--!nolint LocalShadow
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Fusion)
local scoped, peek = Fusion.scoped, Fusion.peek

return function()
	local describe = getfenv().describe

	describe("regression tests", function()
		local it = getfenv().it
	
		it("re-entrant Observers do not block eager updates", function()
			local expect = getfenv().expect

			local scope = scoped(Fusion)

			local count = 0
			local unrelatedValue = scope:Value(count)
			local trigger = scope:Value(false)

			local o1 = scope:Observer(trigger)
			o1:onChange(function()
				count += 1
				unrelatedValue:set(count)
			end)

			local numFires = 0
			local o2 = scope:Observer(trigger)
			o2:onChange(function()
				numFires += 1
			end)

			trigger:set(true)
			expect(numFires).to.equal(1)
			trigger:set(false)
			expect(numFires).to.equal(2)
			trigger:set(true)
			expect(numFires).to.equal(3)

			scope:doCleanup()
		end)
	end)
end