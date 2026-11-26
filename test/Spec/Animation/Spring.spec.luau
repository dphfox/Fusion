--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local External = require(Fusion.External)
local Spring = require(Fusion.Animation.Spring)
local Value = require(Fusion.State.Value)
local peek = require(Fusion.State.peek)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it

	-- Starts a spring moving from 0 towards 1, and returns it along with a
	-- function to advance time relative to when it started moving.
	local function movingSpring(scope)
		local start = External.lastUpdateStep()
		local goal = Value(scope, 0)
		local spring = Spring(scope, goal, 10, 0.5)
		peek(spring)
		goal:set(1)
		External.performUpdateStep(start + 0.05)
		peek(spring)
		External.performUpdateStep(start + 0.1)
		return spring, function(seconds: number)
			External.performUpdateStep(start + 0.1 + seconds)
		end
	end

	it("setVelocity then setPosition in one frame keeps both", function()
		local expect = getfenv().expect

		local scope = {}
		local spring, advance = movingSpring(scope)
		expect(peek(spring) > 0.05).to.equal(true)

		spring:setVelocity(0)
		spring:setPosition(0)
		advance(0.001)
		expect(math.abs(peek(spring)) < 0.001).to.equal(true)

		doCleanup(scope)
	end)

	it("setPosition then setVelocity in one frame keeps both", function()
		local expect = getfenv().expect

		local scope = {}
		local spring, advance = movingSpring(scope)
		expect(peek(spring) > 0.05).to.equal(true)

		spring:setPosition(0)
		spring:setVelocity(0)
		advance(0.001)
		expect(math.abs(peek(spring)) < 0.001).to.equal(true)

		doCleanup(scope)
	end)

	it("accumulates multiple addVelocity calls in one frame", function()
		local expect = getfenv().expect

		local scope = {}
		local start = External.lastUpdateStep()
		local spring = Spring(scope, Value(scope, 0), 10, 0.5)
		peek(spring)
		External.performUpdateStep(start + 0.1)
		peek(spring)

		spring:addVelocity(5)
		spring:addVelocity(5)
		External.performUpdateStep(start + 0.101)
		-- ~10 units per second for 1 millisecond
		expect(peek(spring) > 0.008).to.equal(true)

		doCleanup(scope)
	end)
end
