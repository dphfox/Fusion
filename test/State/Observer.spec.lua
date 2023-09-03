local Package = game:GetService("ReplicatedStorage").Fusion
local Observer = require(Package.State.Observer)
local Value = require(Package.State.Value)
local peek = require(Package.State.peek)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	it("constructs in scopes", function()
		local scope = {}
		local dependency = Value(scope, 5)
		local observer = Observer(scope, dependency)

		expect(observer).to.be.a("table")
		expect(observer.type).to.equal("State")
		expect(observer.kind).to.equal("Observer")
		expect(scope[2]).to.equal(observer)

		doCleanup(scope)
	end)

	it("is destroyable", function()
		local scope = {}
		local dependency = Value(scope, 5)
		local observer = Observer(scope, dependency)
		expect(function()
			observer:destroy()
		end).to.never.throw()
	end)

	it("fires once after change", function()
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
		local scope = {}
		local dependency = Value(scope, 5)
		local observer = Observer(scope, dependency)
		local numFires = 0
		local disconnect = observer:onChange(function()
			task.wait(1)
			numFires += 1
		end)
		dependency:set(15)
		disconnect()

		expect(numFires).to.equal(0)

		doCleanup(scope)
	end)

	it("fires onBind at bind time", function()
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
		local scope = {}
		local dependency = Value(scope, 5)
		local observer = Observer({}, dependency)
		local numFires = 0
		local _ = observer:onChange(function()
			numFires += 1
		end)
		dependency:set(15)
		observer:destroy()
		dependency:set(2)

		expect(numFires).to.equal(1)

		doCleanup(scope)
	end)

end
