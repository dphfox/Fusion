--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local Computed = require(Fusion.State.Computed)
local Value = require(Fusion.State.Value)
local peek = require(Fusion.State.peek)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it

	it("constructs in scopes", function()
		local expect = getfenv().expect
		
		local scope = {}
		local computed = Computed(scope, function()
			-- intentionally blank
		end :: any)

		expect(computed).to.be.a("table")
		expect(computed.type).to.equal("State")
		expect(computed.kind).to.equal("Computed")
		expect(table.find(scope, computed.oldestTask :: any)).never.to.equal(nil)

		doCleanup(scope)
	end)

	it("is destroyable", function()
		local expect = getfenv().expect
		
		local scope = {}
		local computed = Computed(scope, function()
			-- intentionally blank
		end :: any)
		expect(function()
			doCleanup(computed)
		end).to.never.throw()
	end)

	it("computes with constants", function()
		local expect = getfenv().expect
		
		local scope = {}
		local computed = Computed(scope, function(use)
			return use(5)
		end)
		expect(peek(computed)).to.equal(5)
		doCleanup(scope)
	end)

	it("computes with state objects", function()
		local expect = getfenv().expect
		
		local scope = {}
		local dependency = Value(scope, 5 :: number | string)
		local computed = Computed(scope, function(use)
			return use(dependency)
		end)
		expect(peek(computed)).to.equal(5)
		dependency:set("foo")
		expect(peek(computed)).to.equal("foo")
		doCleanup(scope)
	end)

	it("preserves value on error", function()
		local expect = getfenv().expect
		
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

	it("doesn't destroy inner scope on creation", function()
		local expect = getfenv().expect
		
		local scope = {}
		local destructed = false
		local computed = Computed(scope, function(_, innerScope)
			table.insert(innerScope :: any, function()
				destructed = true
			end)
		end :: any)
		peek(computed)
		expect(destructed).to.equal(false)

		doCleanup(scope)
	end)

	it("destroys inner scope on update", function()
		local expect = getfenv().expect
		
		local scope = {}
		local destructed = {}
		local dependency = Value(scope, 1)
		local computed = Computed(scope, function(use, innerScope)
			local value = use(dependency)
			table.insert(innerScope, function()
				destructed[value] = true
			end)
			return use(dependency)
		end)
		peek(computed)
		expect(destructed[1]).to.equal(nil)
		dependency:set(2)
		peek(computed)
		expect(destructed[1]).to.equal(true)
		expect(destructed[2]).to.equal(nil)
		dependency:set(3)
		peek(computed)
		expect(destructed[2]).to.equal(true)

		doCleanup(scope)
	end)

	it("destroys errored values and preserves the last non-error value", function()
		local expect = getfenv().expect
		
		local scope = {}
		local numDestructions = {}
		local dependency = Value(scope, 1)
		local computed = Computed(scope, function(use, innerScope)
			local value = use(dependency)
			table.insert(innerScope, function()
				numDestructions[value] = (numDestructions[value] or 0) + 1
			end)
			assert(value ~= 2, "This is an intentional error from a unit test")
			return value
		end)
		peek(computed)
		expect(numDestructions[1]).to.equal(nil)
		dependency:set(2)
		peek(computed)
		expect(numDestructions[1]).to.equal(nil)
		expect(numDestructions[2]).to.equal(1)
		dependency:set(3)
		peek(computed)
		expect(numDestructions[2]).to.equal(1)
		expect(numDestructions[3]).to.equal(nil)
		dependency:set(4)
		peek(computed)
		expect(numDestructions[3]).to.equal(1)

		doCleanup(scope)
	end)

	it("destroys inner scope on destroy", function()
		local expect = getfenv().expect
		
		local scope = {}
		local destructed = false
		local computed = Computed(scope, function(use, innerScope)
			table.insert(innerScope, function()
				destructed = true
			end)
		end :: any)
		peek(computed)
		doCleanup(scope)
		expect(destructed).to.equal(true)
	end)
end
