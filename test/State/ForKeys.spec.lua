local Package = game:GetService("ReplicatedStorage").Fusion
local ForKeys = require(Package.State.ForKeys)
local Value = require(Package.State.Value)
local peek = require(Package.State.peek)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	FOCUS()
	it("constructs in scopes", function()
		local scope = {}
		local forObject = ForKeys(scope, {}, function()
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
		local forObject = ForKeys(scope, {}, function()
			-- intentionally blank
		end)
		expect(function()
			forObject:destroy()
		end).to.never.throw()
	end)

	it("iterates on constants", function()
		local scope = {}
		local data = {foo = 1, bar = 2}
		local forObject = ForKeys(scope, data, function(_, _, key)
			return key:upper()
		end)
		expect(peek(forObject)).to.be.a("table")
		expect(peek(forObject).FOO).to.equal(1)
		expect(peek(forObject).BAR).to.equal(2)
		doCleanup(scope)
	end)

	it("iterates on state objects", function()
		local scope = {}
		local data = Value(scope, {foo = 1, bar = 2})
		local forObject = ForKeys(scope, data, function(_, _, key)
			return key:upper()
		end)
		expect(peek(forObject)).to.be.a("table")
		expect(peek(forObject).FOO).to.equal(1)
		expect(peek(forObject).BAR).to.equal(2)
		data:set({baz = 3, garb = 4})
		expect(peek(forObject).FOO).to.equal(nil)
		expect(peek(forObject).BAR).to.equal(nil)
		expect(peek(forObject).BAZ).to.equal(3)
		expect(peek(forObject).GARB).to.equal(4)
		doCleanup(scope)
	end)

	it("computes with constants", function()
		local scope = {}
		local data = {foo = 1, bar = 2}
		local forObject = ForKeys(scope, data, function(_, use, key)
			return key .. use("baz")
		end)
		expect(peek(forObject).foobaz).to.equal(1)
		expect(peek(forObject).barbaz).to.equal(2)
		doCleanup(scope)
	end)

	it("computes with state objects", function()
		local scope = {}
		local data = {foo = 1, bar = 2}
		local suffix = Value(scope, "first")
		local forObject = ForKeys(scope, data, function(_, use, key)
			return key .. use(suffix)
		end)
		expect(peek(forObject).foofirst).to.equal(1)
		expect(peek(forObject).barfirst).to.equal(2)
		suffix:set("second")
		expect(peek(forObject).foofirst).to.equal(nil)
		expect(peek(forObject).barfirst).to.equal(nil)
		expect(peek(forObject).foosecond).to.equal(1)
		expect(peek(forObject).barsecond).to.equal(2)
		doCleanup(scope)
	end)

	it("destroys and omits keys that error during processing", function()
		local scope = {}
		local data = {foo = 1, bar = 2, baz = 3}
		local suffix = Value(scope, "first")
		local destroyed = {}
		local forObject = ForKeys(scope, data, function(innerScope, use, key)
			local generated = key .. use(suffix)
			table.insert(innerScope, function()
				destroyed[generated] = true
			end)
			if key == "bar" and use(suffix) == "second" then
				error("This is an intentional error from a unit test")
			end
			return generated
		end)
		expect(peek(forObject).foofirst).to.equal(1)
		expect(peek(forObject).barfirst).to.equal(2)
		expect(peek(forObject).bazfirst).to.equal(3)
		suffix:set("second")
		expect(peek(forObject).foofirst).to.equal(nil)
		expect(peek(forObject).barfirst).to.equal(nil)
		expect(peek(forObject).bazfirst).to.equal(nil)
		expect(peek(forObject).foosecond).to.equal(1)
		expect(peek(forObject).barsecond).to.equal(nil)
		expect(peek(forObject).bazsecond).to.equal(3)
		expect(destroyed.foofirst).to.equal(true)
		expect(destroyed.barfirst).to.equal(true)
		expect(destroyed.bazfirst).to.equal(true)
		expect(destroyed.foosecond).to.equal(nil)
		expect(destroyed.barsecond).to.equal(true)
		expect(destroyed.bazsecond).to.equal(nil)
		suffix:set("third")
		expect(peek(forObject).foofirst).to.equal(nil)
		expect(peek(forObject).barfirst).to.equal(nil)
		expect(peek(forObject).bazfirst).to.equal(nil)
		expect(peek(forObject).foosecond).to.equal(nil)
		expect(peek(forObject).barsecond).to.equal(nil)
		expect(peek(forObject).bazsecond).to.equal(nil)
		expect(peek(forObject).foothird).to.equal(1)
		expect(peek(forObject).barthird).to.equal(2)
		expect(peek(forObject).bazthird).to.equal(3)
		doCleanup(scope)
	end)

	it("omits keys that return nil", function()
		local scope = {}
		local data = {foo = 1, bar = 2, baz = 3}
		local omitThird = Value(scope, false)
		local forObject = ForKeys(scope, data, function(_, use, key)
			if key == "bar" then
				return nil
			end
			if use(omitThird) then
				if key == "baz" then
					return nil
				end
			end
			return key
		end)
		expect(peek(forObject).foo).to.equal(1)
		expect(peek(forObject).bar).to.equal(nil)
		expect(peek(forObject).baz).to.equal(3)
		omitThird:set(true)
		expect(peek(forObject).foo).to.equal(1)
		expect(peek(forObject).bar).to.equal(nil)
		expect(peek(forObject).baz).to.equal(nil)
		omitThird:set(false)
		expect(peek(forObject).foo).to.equal(1)
		expect(peek(forObject).bar).to.equal(nil)
		expect(peek(forObject).baz).to.equal(3)
		doCleanup(scope)
	end)

	it("doesn't destroy inner scope on creation", function()
		local scope = {}
		local destructed = {}
		local data = Value(scope, {foo = 1, bar = 2})
		local _ = ForKeys(scope, data, function(innerScope, _, key)
			table.insert(innerScope, function()
				destructed[key] = true
			end)
			return key
		end)
		expect(destructed.foo).to.equal(nil)
		expect(destructed.bar).to.equal(nil)
		data:set({foo = 1, bar = 2, baz = 3})
		expect(destructed.foo).to.equal(nil)
		expect(destructed.bar).to.equal(nil)
		expect(destructed.baz).to.equal(nil)
		doCleanup(scope)
	end)

	it("destroys inner scope on update", function()
		local scope = {}
		local destructed = {}
		local data = Value(scope, {foo = 1, bar = 2})
		local _ = ForKeys(scope, data, function(innerScope, _, key)
			table.insert(innerScope, function()
				destructed[key] = true
			end)
			return key
		end)
		expect(destructed.foo).to.equal(nil)
		expect(destructed.bar).to.equal(nil)
		data:set({baz = 3})
		expect(destructed.foo).to.equal(true)
		expect(destructed.bar).to.equal(true)
		expect(destructed.baz).to.equal(nil)
		doCleanup(scope)
	end)

	it("destroys inner scope on destroy", function()
		local scope = {}
		local destructed = {}
		local data = Value(scope, {foo = 1, bar = 2})
		local _ = ForKeys(scope, data, function(innerScope, _, key)
			table.insert(innerScope, function()
				destructed[key] = true
			end)
			return key
		end)
		expect(destructed.foo).to.equal(nil)
		expect(destructed.bar).to.equal(nil)
		doCleanup(scope)
		expect(destructed.foo).to.equal(true)
		expect(destructed.bar).to.equal(true)
	end)

	it("doesn't recompute when values chaneg", function()
		local scope = {}
		local data = Value(scope, {foo = 1, bar = 2})
		local computations = 0
		local _ = ForKeys(scope, data, function(innerScope, _, key)
			computations += 1
			return string.upper(key)
		end)
		expect(computations).to.equal(2)
		data:set({foo = 3, bar = 4})
		expect(computations).to.equal(2)
		data:set({foo = 3, bar = 4, baz = 5})
		expect(computations).to.equal(3)
		data:set({foo = 4, bar = 5, baz = 6})
		expect(computations).to.equal(3)
		doCleanup(scope)
	end)
end
