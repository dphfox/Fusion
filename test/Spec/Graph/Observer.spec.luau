--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local Observer = require(Fusion.Graph.Observer)
local Value = require(Fusion.State.Value)
local Computed = require(Fusion.State.Computed)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it

	it("constructs in scopes", function()
		local expect = getfenv().expect
		
		local scope = {}
		local dependency = Value(scope, 5)
		local observer = Observer(scope, dependency)

		expect(observer).to.be.a("table")
		expect(observer.type).to.equal("Observer")
		expect(scope[2]).to.equal(observer)

		doCleanup(scope)
	end)

	it("is destroyable", function()
		local expect = getfenv().expect
		
		local scope = {}
		local dependency = Value(scope, 5)
		local observer = Observer(scope, dependency)
		expect(function()
			observer:destroy()
		end).to.never.throw()
	end)

	it("fires once after change", function()
		local expect = getfenv().expect
		
		local scope = {}
		local dependency = Value(scope, 5)
		local observer = Observer(scope, dependency)
		local numFires = 0
		local disconnect = observer:onChange(function()
			numFires += 1
		end)
		dependency:set(15)
		disconnect()

		expect(numFires).to.equal(1)

		doCleanup(scope)
	end)

	it("fires asynchronously", function()
		local expect = getfenv().expect
		
		local scope = {}
		local dependency = Value(scope, 5)
		local observer = Observer(scope, dependency)

		local firesPerThread = {} :: {[thread]: number}

		for i=1, 5 do
			observer:onChange(function()
				local thread = coroutine.running()
				firesPerThread[thread] = (firesPerThread[thread] or 0) + 1
			end)
		end
		dependency:set(10)

		for _, numFires in firesPerThread do
			expect(numFires).to.equal(1)
		end

		doCleanup(scope)
	end)

	it("fires onBind at bind time", function()
		local expect = getfenv().expect
		
		local scope = {}
		local dependency = Value(scope, 5)
		local observer = Observer(scope, dependency)
		local numFires = 0
		local disconnect = observer:onBind(function()
			numFires += 1
		end)
		disconnect()

		expect(numFires).to.equal(1)

		doCleanup(scope)
	end)

	it("disconnects manually", function()
		local expect = getfenv().expect
		
		local scope = {}
		local dependency = Value(scope, 5)
		local observer = Observer(scope, dependency)
		local numFires = 0
		local disconnect = observer:onChange(function()
			numFires += 1
		end)
		dependency:set(15)
		disconnect()
		dependency:set(2)

		expect(numFires).to.equal(1)

		doCleanup(scope)
	end)

	it("disconnects on destroy", function()
		local expect = getfenv().expect
		
		local scope = {}
		local dependency = Value(scope, 5)
		
		local subScope = {}
		table.insert(scope, subScope)
		local observer = Observer(subScope, dependency)

		local numFires = 0
		local _ = observer:onChange(function()
			numFires += 1
		end)
		dependency:set(15)
		doCleanup(subScope)
		dependency:set(2)

		expect(numFires).to.equal(1)

		doCleanup(scope)
	end)

	it("never fires onChange for constants", function()
		local expect = getfenv().expect
		
		local scope = {}
		local observer = Observer(scope, 5)
		local numFires = 0
		local disconnect = observer:onChange(function()
			numFires += 1
		end)
		expect(numFires).to.equal(0)

		doCleanup(scope)
	end)

	it("fires onBind at bind time for constants", function()
		local expect = getfenv().expect
		
		local scope = {}
		local observer = Observer(scope, 5)
		local numFires = 0
		local disconnect = observer:onBind(function()
			numFires += 1
		end)
		disconnect()

		expect(numFires).to.equal(1)

		doCleanup(scope)
	end)

	it("ensures dependencies are captured for unobserved lazy inputs", function()
		local expect = getfenv().expect
		
		local scope = {}
		local value = Value(scope, 5)
		local double = Computed(scope, function(use)
			return use(value) * 2
		end)
		local numFires = 0
		Observer(scope, double):onChange(function()
			numFires += 1
		end)

		expect(numFires).to.equal(0)
		value:set(10)
		expect(numFires).to.equal(1)

		doCleanup(scope)
	end)

end
