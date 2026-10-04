--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion
-- Cloned modules do not have statically resolvable require paths.
local requireIsolated = require :: any

return function()
	local it = getfenv().it
	local beforeEach = getfenv().beforeEach
	local afterEach = getfenv().afterEach

	local isolatedFusion
	local External: typeof(require(Fusion.External))
	local RobloxExternal: typeof(require(Fusion.RobloxExternal))
	local scope

	beforeEach(function()
		-- Each test needs the same initial clock state as a fresh require.
		isolatedFusion = Fusion:Clone()
		External = requireIsolated(isolatedFusion.External)
		RobloxExternal = requireIsolated(isolatedFusion.RobloxExternal)
		scope = {}
	end)

	afterEach(function()
		RobloxExternal.stopScheduler()
		local doCleanup = requireIsolated(isolatedFusion.Memory.doCleanup)
		doCleanup(scope)
		isolatedFusion:Destroy()
	end)

	it("initialises the update time before the first frame", function()
		local expect = getfenv().expect
		local before = os.clock()
		RobloxExternal.startScheduler()
		local after = os.clock()

		local initialTime = External.lastUpdateStep()
		expect(initialTime >= before).to.equal(true)
		expect(initialTime <= after).to.equal(true)
	end)

	it("only initialises the update time when the scheduler starts", function()
		local expect = getfenv().expect
		local updateCount = 0
		External.bindToUpdateStep(function()
			updateCount += 1
			if updateCount == 1 then
				RobloxExternal.startScheduler()
			end
		end)

		RobloxExternal.startScheduler()
		RobloxExternal.startScheduler()
		expect(updateCount).to.equal(1)

		RobloxExternal.stopScheduler()
		RobloxExternal.startScheduler()
		expect(updateCount).to.equal(2)
	end)

	it("measures only the first frame after the scheduler starts", function()
		local expect = getfenv().expect
		local ExternalTime = requireIsolated(isolatedFusion.Animation.ExternalTime)
		local Stopwatch = requireIsolated(isolatedFusion.Animation.Stopwatch)
		local peek = requireIsolated(isolatedFusion.State.peek)
		local before = os.clock()
		RobloxExternal.startScheduler()
		local after = os.clock()
		local stopwatch = Stopwatch(scope, ExternalTime(scope))
		stopwatch:unpause()

		local frameTime = 1 / 60
		External.performUpdateStep(after + frameTime)
		local elapsed = peek(stopwatch)
		expect(elapsed >= frameTime - 0.00001).to.equal(true)
		expect(elapsed <= after - before + frameTime + 0.00001).to.equal(true)
	end)

	it("keeps a new spring animating through the first frame", function()
		local expect = getfenv().expect
		local Spring = requireIsolated(isolatedFusion.Animation.Spring)
		local Value = requireIsolated(isolatedFusion.State.Value)
		local peek = requireIsolated(isolatedFusion.State.peek)
		local before = os.clock()
		RobloxExternal.startScheduler()
		local after = os.clock()
		local spring = Spring(scope, Value(scope, 0), 1, 1)
		spring:setPosition(1)

		local frameTime = 1 / 60
		External.performUpdateStep(after + frameTime)
		local longestElapsed = after - before + frameTime
		local position = peek(spring)
		-- A critically damped spring with zero initial velocity follows
		-- (1 + t) * exp(-t), with the start time bounded by the samples above.
		expect(position >= (1 + longestElapsed) * math.exp(-longestElapsed) - 0.00001).to.equal(true)
		expect(position <= (1 + frameTime) * math.exp(-frameTime) + 0.00001).to.equal(true)
	end)
end
