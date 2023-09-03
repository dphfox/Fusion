local Package = game:GetService("ReplicatedStorage").Fusion
local Computed = require(Package.State.Computed)
local Value = require(Package.State.Value)
local peek = require(Package.State.peek)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	it("constructs in scopes", function()
		local scope = {}
		local computed = Computed(scope, function()
			-- intentionally blank
		end)

		expect(computed).to.be.a("table")
		expect(computed.type).to.equal("State")
		expect(computed.kind).to.equal("Computed")
		expect(scope[1]).to.equal(computed)

		doCleanup(scope)
	end)

	it("is destroyable", function()
		local scope = {}
		local computed = Computed(scope, function()
			-- intentionally blank
		end)
		expect(function()
			computed:destroy()
		end).to.never.throw()
	end)

	it("computes with constants", function()
		local scope = {}
		local computed = Computed(scope, function(use)
			return use(5)
		end)
		expect(peek(computed)).to.equal(5)
		doCleanup(scope)
	end)

	it("computes with state objects", function()
		local scope = {}
		local dependency = Value(scope, 5)
		local computed = Computed(scope, function(use)
			return use(dependency)
		end)
		expect(peek(computed)).to.equal(5)
		dependency:set("foo")
		expect(peek(computed)).to.equal("foo")
		doCleanup(scope)
	end)

	it("preserves value on error", function()
		local scope = {}
		local dependency = Value(scope, 5)
		local computed = Computed(scope, function(use)
			assert(use(dependency) ~= 13, "This is an intentional error from a unit test")
			return use(dependency)
		end)
		expect(peek(computed)).to.equal(5)
		dependency:set(13) -- this will invoke the error
		expect(peek(computed)).to.equal(5)
		dependency:set(2)
		expect(peek(computed)).to.equal(2)
		doCleanup(scope)
	end)

	it("doesn't call destructor on creation", function()
		local scope = {}
		local destructed = false
		local _ = Computed(scope, function()
			-- intentionally blank
		end, function()
			destructed = true
		end)
		expect(destructed).to.equal(false)

		doCleanup(scope)
	end)

	it("calls destructor on update", function()
		local scope = {}
		local destructed = {}
		local dependency = Value(scope, 1)
		local _ = Computed(scope, function(use)
			return use(dependency)
		end, function(value)
			destructed[value] = true
		end)
		expect(destructed[1]).to.equal(nil)
		dependency:set(2)
		expect(destructed[1]).to.equal(true)
		expect(destructed[2]).to.equal(nil)
		dependency:set(3)
		expect(destructed[2]).to.equal(true)

		doCleanup(scope)
	end)

	it("calls destructor on destroy", function()
		local scope = {}
		local destructed = {}
		local dependency = Value(scope, 1)
		local _ = Computed(scope, function(use)
			return use(dependency)
		end, function(value)
			destructed[value] = true
		end)
		expect(destructed[1]).to.equal(nil)
		doCleanup(scope)
		expect(destructed[1]).to.equal(true)
	end)
end
