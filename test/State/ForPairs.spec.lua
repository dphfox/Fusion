local RunService = game:GetService("RunService")

local Package = game:GetService("ReplicatedStorage").Fusion
local ForPairs = require(Package.State.ForPairs)
local Value = require(Package.State.Value)
local peek = require(Package.State.peek)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	it("constructs in scopes", function()
		local scope = {}
		local forObject = ForPairs(scope, {}, function()
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
		local forObject = ForPairs(scope, {}, function()
			-- intentionally blank
		end)
		expect(function()
			forObject:destroy()
		end).to.never.throw()
	end)

	it("iterates on constants", function()
		local scope = {}
		local data = {foo = "oof", bar = "rab"}
		local forObject = ForPairs(scope, data, function(_, _, key, value)
			return value, key
		end)
		expect(peek(forObject)).to.be.a("table")
		expect(peek(forObject).oof).to.equal("foo")
		expect(peek(forObject).rab).to.equal("bar")
		doCleanup(scope)
	end)

	it("iterates on state objects", function()
		local scope = {}
		local data = Value(scope, {foo = "oof", bar = "rab"})
		local forObject = ForPairs(scope, data, function(_, _, key, value)
			return value, key
		end)
		expect(peek(forObject)).to.be.a("table")
		expect(peek(forObject).oof).to.equal("foo")
		expect(peek(forObject).rab).to.equal("bar")
		data:set({baz = "zab", garb = "brag"})
		expect(peek(forObject).oof).to.equal(nil)
		expect(peek(forObject).rab).to.equal(nil)
		expect(peek(forObject).zab).to.equal("baz")
		expect(peek(forObject).brag).to.equal("garb")
		doCleanup(scope)
	end)

	it("computes with constants", function()
		local scope = {}
		local data = {foo = "oof", bar = "rab"}
		local forObject = ForPairs(scope, data, function(use, _, key, value)
			return value .. use("baz"), key .. use("baz")
		end)
		expect(peek(forObject).oofbaz).to.equal("foobaz")
		expect(peek(forObject).rabbaz).to.equal("barbaz")
		doCleanup(scope)
	end)

	it("computes with state objects", function()
		local scope = {}
		local data = {foo = "oof", bar = "rab"}
		local suffix = Value(scope, "first")
		local forObject = ForPairs(scope, data, function(use, _, key, value)
			return value .. use(suffix), key .. use(suffix)
		end)
		expect(peek(forObject).ooffirst).to.equal("foofirst")
		expect(peek(forObject).rabfirst).to.equal("barfirst")
		suffix:set("second")
		expect(peek(forObject).ooffirst).to.equal(nil)
		expect(peek(forObject).rabfirst).to.equal(nil)
		expect(peek(forObject).oofsecond).to.equal("foosecond")
		expect(peek(forObject).rabsecond).to.equal("barsecond")
		doCleanup(scope)
	end)

	it("destroys and omits pair that error during processing", function()
		local scope = {}
		local data = {foo = "oof", bar = "rab", baz = "zab"}
		local suffix = Value(scope, "first")
		local destroyed = {}
		local forObject = ForPairs(scope, data, function(use, innerScope, key, value)
			local generatedKey = value .. use(suffix)
			local generatedValue = key .. use(suffix)
			table.insert(innerScope, function()
				destroyed[generatedKey] = true
			end)
			if key == "bar" and use(suffix) == "second" then
				error("This is an intentional error from a unit test")
			end
			return generatedKey, generatedValue
		end)
		expect(peek(forObject).ooffirst).to.equal("foofirst")
		expect(peek(forObject).rabfirst).to.equal("barfirst")
		expect(peek(forObject).zabfirst).to.equal("bazfirst")
		suffix:set("second")
		expect(peek(forObject).ooffirst).to.never.equal("foofirst")
		expect(peek(forObject).rabfirst).to.never.equal("barfirst")
		expect(peek(forObject).zabfirst).to.never.equal("bazfirst")
		expect(peek(forObject).oofsecond).to.equal("foosecond")
		expect(peek(forObject).rabsecond).to.never.equal("barsecond")
		expect(peek(forObject).zabsecond).to.equal("bazsecond")
		expect(destroyed.ooffirst).to.equal(true)
		expect(destroyed.rabfirst).to.equal(true)
		expect(destroyed.zabfirst).to.equal(true)
		expect(destroyed.oofsecond).to.equal(nil)
		expect(destroyed.rabsecond).to.equal(true)
		expect(destroyed.zabsecond).to.equal(nil)
		suffix:set("third")
		expect(peek(forObject).ooffirst).to.never.equal("foofirst")
		expect(peek(forObject).rabfirst).to.never.equal("barfirst")
		expect(peek(forObject).zabfirst).to.never.equal("bazfirst")
		expect(peek(forObject).oofsecond).to.never.equal("foosecond")
		expect(peek(forObject).rabsecond).to.never.equal("barsecond")
		expect(peek(forObject).zabsecond).to.never.equal("bazsecond")
		expect(peek(forObject).oofthird).to.equal("foothird")
		expect(peek(forObject).rabthird).to.equal("barthird")
		expect(peek(forObject).zabthird).to.equal("bazthird")
		doCleanup(scope)
	end)

	it("omits values that return nil", function()
		local scope = {}
		local data = {foo = "oof", bar = "rab", baz = "zab"}
		local omitThird = Value(scope, false)
		local forObject = ForPairs(scope, data, function(use, _, key, value)
			if key == "bar" then
				return nil
			end
			if use(omitThird) then
				if key == "baz" then
					return value, nil
				end
			end
			return value, key
		end)
		expect(peek(forObject).oof).to.equal("foo")
		expect(peek(forObject).rab).to.never.equal("bar")
		expect(peek(forObject).zab).to.equal("baz")
		omitThird:set(true)
		expect(peek(forObject).oof).to.equal("foo")
		expect(peek(forObject).rab).to.never.equal("bar")
		expect(peek(forObject).zab).to.never.equal("baz")
		omitThird:set(false)
		expect(peek(forObject).oof).to.equal("foo")
		expect(peek(forObject).rab).to.never.equal("bar")
		expect(peek(forObject).zab).to.equal("baz")
		doCleanup(scope)
	end)

	it("doesn't destroy inner scope on creation", function()
		local scope = {}
		local destructed = {}
		local data = Value(scope, {foo = "oof", bar = "rab", baz = "zab"})
		local _ = ForPairs(scope, data, function(_, innerScope, key, value)
			table.insert(innerScope, function()
				destructed[key] = true
			end)
			return value, key
		end)
		expect(destructed.foo).to.equal(nil)
		expect(destructed.bar).to.equal(nil)
		data:set({foo = "oof", bar = "rab", baz = "zab"})
		expect(destructed.foo).to.equal(nil)
		expect(destructed.bar).to.equal(nil)
		expect(destructed.baz).to.equal(nil)
		doCleanup(scope)
	end)

	it("destroys inner scope on update", function()
		local scope = {}
		local destructed = {}
		local data = Value(scope, {foo = "oof", bar = "rab"})
		local _ = ForPairs(scope, data, function(_, innerScope, key, value)
			table.insert(innerScope, function()
				destructed[key] = true
			end)
			return value, key
		end)
		expect(destructed.foo).to.equal(nil)
		expect(destructed.bar).to.equal(nil)
		data:set({baz = "zab"})
		expect(destructed.foo).to.equal(true)
		expect(destructed.bar).to.equal(true)
		expect(destructed.baz).to.equal(nil)
		doCleanup(scope)
	end)

	it("destroys inner scope on destroy", function()
		local scope = {}
		local destructed = {}
		local data = Value(scope, {foo = "oof", bar = "rab"})
		local _ = ForPairs(scope, data, function(_, innerScope, key, value)
			table.insert(innerScope, function()
				destructed[key] = true
			end)
			return value, key
		end)
		expect(destructed.foo).to.equal(nil)
		expect(destructed.bar).to.equal(nil)
		doCleanup(scope)
		expect(destructed.foo).to.equal(true)
		expect(destructed.bar).to.equal(true)
	end)
end
