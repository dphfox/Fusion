local RunService = game:GetService("RunService")

local Package = game:GetService("ReplicatedStorage").Fusion
local ForValues = require(Package.State.ForValues)
local Value = require(Package.State.Value)
local peek = require(Package.State.peek)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	FOCUS()

	it("constructs in scopes", function()
		local scope = {}
		local forObject = ForValues(scope, {}, function()
			-- intentionally blank
		end)

		expect(forObject).to.be.a("table")
		expect(forObject.type).to.equal("State")
		expect(forObject.kind).to.equal("For")
		expect(scope[1]).to.equal(forObject)

		doCleanup(scope)
	end)

	it("is destroyable", function()
		local scope = {}
		local forObject = ForValues(scope, {}, function()
			-- intentionally blank
		end)
		expect(function()
			forObject:destroy()
		end).to.never.throw()
	end)

	it("iterates on constants", function()
		local scope = {}
		local data = {"foo", "bar"}
		local forObject = ForValues(scope, data, function(_, _, value)
			return value:upper()
		end)
		expect(peek(forObject)).to.be.a("table")
		expect(table.find(peek(forObject), "FOO")).to.be.ok()
		expect(table.find(peek(forObject), "BAR")).to.be.ok()
		doCleanup(scope)
	end)

	it("iterates on state objects", function()
		local scope = {}
		local data = Value(scope, {"foo", "bar"})
		local forObject = ForValues(scope, data, function(_, _, value)
			return value:upper()
		end)
		expect(peek(forObject)).to.be.a("table")
		expect(table.find(peek(forObject), "FOO")).to.be.ok()
		expect(table.find(peek(forObject), "BAR")).to.be.ok()
		data:set({"baz", "garb"})
		expect(table.find(peek(forObject), "FOO")).to.never.be.ok()
		expect(table.find(peek(forObject), "BAR")).to.never.be.ok()
		expect(table.find(peek(forObject), "BAZ")).to.be.ok()
		expect(table.find(peek(forObject), "GARB")).to.be.ok()
		doCleanup(scope)
	end)

	it("computes with constants", function()
		local scope = {}
		local data = {"foo", "bar"}
		local forObject = ForValues(scope, data, function(_, use, value)
			return value .. use("baz")
		end)
		expect(table.find(peek(forObject), "foobaz")).to.be.ok()
		expect(table.find(peek(forObject), "barbaz")).to.be.ok()
		doCleanup(scope)
	end)

	it("computes with state objects", function()
		local scope = {}
		local data = {"foo", "bar"}
		local suffix = Value(scope, "first")
		local forObject = ForValues(scope, data, function(_, use, value)
			return value .. use(suffix)
		end)
		expect(table.find(peek(forObject), "foofirst")).to.be.ok()
		expect(table.find(peek(forObject), "barfirst")).to.be.ok()
		suffix:set("second")
		expect(table.find(peek(forObject), "foosecond")).to.be.ok()
		expect(table.find(peek(forObject), "barsecond")).to.be.ok()
		doCleanup(scope)
	end)

	it("destroys and omits values that error during processing", function()
		local scope = {}
		local data = {"foo", "bar", "baz"}
		local suffix = Value(scope, "first")
		local destroyed = {}
		local forObject = ForValues(scope, data, function(innerScope, use, value)
			local generated = value .. use(suffix)
			table.insert(innerScope, function()
				destroyed[generated] = true
			end)
			if value == "bar" and use(suffix) == "second" then
				error("This is an intentional error from a unit test")
			end
			return generated
		end)
		expect(table.find(peek(forObject), "foofirst")).to.be.ok()
		expect(table.find(peek(forObject), "barfirst")).to.be.ok()
		expect(table.find(peek(forObject), "bazfirst")).to.be.ok()
		suffix:set("second")
		expect(table.find(peek(forObject), "foofirst")).to.never.be.ok()
		expect(table.find(peek(forObject), "barfirst")).to.never.be.ok()
		expect(table.find(peek(forObject), "bazfirst")).to.never.be.ok()
		expect(table.find(peek(forObject), "foosecond")).to.be.ok()
		expect(table.find(peek(forObject), "barsecond")).to.never.be.ok()
		expect(table.find(peek(forObject), "bazsecond")).to.be.ok()
		expect(destroyed.foofirst).to.equal(true)
		expect(destroyed.barfirst).to.equal(true)
		expect(destroyed.bazfirst).to.equal(true)
		expect(destroyed.foosecond).to.equal(nil)
		expect(destroyed.barsecond).to.equal(true)
		expect(destroyed.bazsecond).to.equal(nil)
		suffix:set("third")
		expect(table.find(peek(forObject), "foofirst")).to.never.be.ok()
		expect(table.find(peek(forObject), "barfirst")).to.never.be.ok()
		expect(table.find(peek(forObject), "bazfirst")).to.never.be.ok()
		expect(table.find(peek(forObject), "foosecond")).to.never.be.ok()
		expect(table.find(peek(forObject), "barsecond")).to.never.be.ok()
		expect(table.find(peek(forObject), "bazsecond")).to.never.be.ok()
		expect(table.find(peek(forObject), "foothird")).to.be.ok()
		expect(table.find(peek(forObject), "barthird")).to.be.ok()
		expect(table.find(peek(forObject), "bazthird")).to.be.ok()
		doCleanup(scope)
	end)

	it("omits values that return nil", function()
		local scope = {}
		local data = {"foo", "bar", "baz"}
		local omitThird = Value(scope, false)
		local forObject = ForValues(scope, data, function(_, use, value)
			if value == "bar" then
				return nil
			end
			if use(omitThird) then
				if value == "baz" then
					return nil
				end
			end
			return value
		end)
		expect(table.find(peek(forObject), "foo")).to.be.ok()
		expect(table.find(peek(forObject), "bar")).to.never.be.ok()
		expect(table.find(peek(forObject), "baz")).to.be.ok()
		omitThird:set(true)
		expect(table.find(peek(forObject), "foo")).to.be.ok()
		expect(table.find(peek(forObject), "bar")).to.never.be.ok()
		expect(table.find(peek(forObject), "baz")).to.never.be.ok()
		omitThird:set(false)
		expect(table.find(peek(forObject), "foo")).to.be.ok()
		expect(table.find(peek(forObject), "bar")).to.never.be.ok()
		expect(table.find(peek(forObject), "baz")).to.be.ok()
		doCleanup(scope)
	end)

	it("doesn't destroy inner scope on creation", function()
		local scope = {}
		local destructed = {}
		local data = Value(scope, {"foo", "bar"})
		local _ = ForValues(scope, data, function(innerScope, _, value)
			table.insert(innerScope, function()
				destructed[value] = true
			end)
			return value
		end)
		expect(destructed.foo).to.equal(nil)
		expect(destructed.bar).to.equal(nil)
		data:set({"foo", "bar", "baz"})
		expect(destructed.foo).to.equal(nil)
		expect(destructed.bar).to.equal(nil)
		expect(destructed.baz).to.equal(nil)
		doCleanup(scope)
	end)

	it("destroys inner scope on update", function()
		local scope = {}
		local destructed = {}
		local data = Value(scope, {"foo", "bar"})
		local _ = ForValues(scope, data, function(innerScope, _, value)
			table.insert(innerScope, function()
				destructed[value] = true
			end)
			return value
		end)
		expect(destructed.foo).to.equal(nil)
		expect(destructed.bar).to.equal(nil)
		data:set({"baz"})
		expect(destructed.foo).to.equal(true)
		expect(destructed.bar).to.equal(true)
		expect(destructed.baz).to.equal(nil)
		doCleanup(scope)
	end)

	it("destroys inner scope on destroy", function()
		local scope = {}
		local destructed = {}
		local data = Value(scope, {"foo", "bar"})
		local _ = ForValues(scope, data, function(innerScope, _, value)
			table.insert(innerScope, function()
				destructed[value] = true
			end)
			return value
		end)
		expect(destructed.foo).to.equal(nil)
		expect(destructed.bar).to.equal(nil)
		doCleanup(scope)
		expect(destructed.foo).to.equal(true)
		expect(destructed.bar).to.equal(true)
	end)

	it("doesn't recompute when values roam between keys", function()
		local scope = {}
		local data = Value(scope, {"foo", "bar"})
		local computations = 0
		local forObject = ForValues(scope, data, function(_, _, value)
			computations += 1
			return string.upper(value)
		end)
		expect(computations).to.equal(2)
		data:set({"bar", "foo"})
		expect(computations).to.equal(2)
		data:set({"baz", "bar", "foo"})
		expect(computations).to.equal(3)
		data:set({"foo", "baz", "bar"})
		expect(computations).to.equal(3)
		data:set({"garb"})
		expect(computations).to.equal(4)
		doCleanup(scope)
	end)

	it("does not reuse values for duplicated items", function()
		local scope = {}
		local data = Value(scope, {"foo", "foo", "foo"})
		local computations = 0
		local forObject = ForValues(scope, data, function(_, _, value)
			computations += 1
			return string.upper(value)
		end)
		expect(computations).to.equal(3)
		data:set({"foo", "foo", "foo", "foo"})
		expect(computations).to.equal(4)
		data:set({"bar", "foo", "foo"})
		expect(computations).to.equal(5)
		doCleanup(scope)
	end)
end
