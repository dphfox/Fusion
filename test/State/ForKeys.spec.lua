local Package = game:GetService("ReplicatedStorage").Fusion
local ForKeys = require(Package.State.ForKeys)
local Value = require(Package.State.Value)
local peek = require(Package.State.peek)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	it("constructs in scopes", function()
		local scope = {}
		local forkeys = ForKeys(scope, {}, function()
			-- intentionally blank
		end)

		expect(forkeys).to.be.a("table")
		expect(forkeys.type).to.equal("State")
		expect(forkeys.kind).to.equal("ForKeys")
		expect(scope[1]).to.equal(forkeys)

		doCleanup(scope)
	end)

	it("is destroyable", function()
		local scope = {}
		local forkeys = ForKeys(scope, {}, function()
			-- intentionally blank
		end)
		expect(function()
			forkeys:destroy()
		end).to.never.throw()
	end)

	it("iterates on constants", function()
		local scope = {}
		local data = {foo = 1, bar = 2}
		local forkeys = ForKeys(scope, data, function(_, key)
			return key:upper()
		end)
		expect(peek(forkeys)).to.be.a("table")
		expect(peek(forkeys).FOO).to.equal(1)
		expect(peek(forkeys).BAR).to.equal(2)
		doCleanup(scope)
	end)

	it("iterates on state objects", function()
		local scope = {}
		local data = Value(scope, {foo = 1, bar = 2})
		local forkeys = ForKeys(scope, data, function(_, key)
			return key:upper()
		end)
		expect(peek(forkeys)).to.be.a("table")
		expect(peek(forkeys).FOO).to.equal(1)
		expect(peek(forkeys).BAR).to.equal(2)
		doCleanup(scope)
	end)

	it("computes with constants", function()
		local scope = {}
		local data = {foo = 1, bar = 2}
		local forkeys = ForKeys(scope, data, function(use, key)
			return key .. use("baz")
		end)
		expect(peek(forkeys).foobaz).to.equal(1)
		expect(peek(forkeys).barbaz).to.equal(2)
		doCleanup(scope)
	end)

	it("computes with state objects", function()
		local scope = {}
		local data = {foo = 1, bar = 2}
		local suffix = Value(scope, "first")
		local forkeys = ForKeys(scope, data, function(use, key)
			return key .. use(suffix)
		end)
		expect(peek(forkeys).foofirst).to.equal(1)
		expect(peek(forkeys).barfirst).to.equal(2)
		suffix:set("second")
		expect(peek(forkeys).foofirst).to.equal(nil)
		expect(peek(forkeys).barfirst).to.equal(nil)
		expect(peek(forkeys).foosecond).to.equal(1)
		expect(peek(forkeys).barsecond).to.equal(2)
		doCleanup(scope)
	end)

	it("rejects key collisions", function()
		expect(function()
			local scope = {}
			local data = {foo = 1, bar = 2}
			local _ = ForKeys(scope, data, function(use, key)
				return "samuel"
			end)
			doCleanup(scope)
		end).to.throw("forKeysKeyCollision")
	end)

	it("preserves value on error", function()
		local scope = {}
		local data = {foo = 1, bar = 2}
		local suffix = Value(scope, "first")
		local forkeys = ForKeys(scope, data, function(use, key)
			assert(use(suffix) ~= "second", "This is an intentional error from a unit test")
			return key .. use(suffix)
		end)
		expect(peek(forkeys).foofirst).to.equal(1)
		expect(peek(forkeys).barfirst).to.equal(2)
		suffix:set("second") -- will invoke the error
		expect(peek(forkeys).foofirst).to.equal(1)
		expect(peek(forkeys).barfirst).to.equal(2)
		expect(peek(forkeys).foosecond).to.equal(nil)
		expect(peek(forkeys).barsecond).to.equal(nil)
		suffix:set("third")
		expect(peek(forkeys).foofirst).to.equal(nil)
		expect(peek(forkeys).barfirst).to.equal(nil)
		expect(peek(forkeys).foosecond).to.equal(nil)
		expect(peek(forkeys).barsecond).to.equal(nil)
		expect(peek(forkeys).foothird).to.equal(1)
		expect(peek(forkeys).barthird).to.equal(2)
		doCleanup(scope)
	end)

	it("doesn't call destructor on creation", function()
		local scope = {}
		local destructed = {}
		local data = Value(scope, {foo = 1, bar = 2})
		local _ = ForKeys(scope, data, function(use, key)
			return key, "meta" .. key
		end, function(key, meta)
			destructed[key] = true
			destructed[meta] = true
		end)
		expect(destructed.foo).to.equal(nil)
		expect(destructed.foometa).to.equal(nil)
		expect(destructed.bar).to.equal(nil)
		expect(destructed.barmeta).to.equal(nil)
		doCleanup(scope)
	end)

	it("calls destructor on update", function()
		local scope = {}
		local destructed = {}
		local data = Value(scope, {foo = 1, bar = 2})
		local _ = ForKeys(scope, data, function(use, key)
			return key, "meta" .. key
		end, function(key, meta)
			destructed[key] = true
			destructed[meta] = true
		end)
		data:set({foo = 100, baz = 3})
		expect(destructed.foo).to.equal(nil)
		expect(destructed.foometa).to.equal(nil)
		expect(destructed.bar).to.equal(true)
		expect(destructed.barmeta).to.equal(true)
		doCleanup(scope)
	end)

	it("calls destructor on destroy", function()
		local scope = {}
		local destructed = {}
		local data = Value(scope, {foo = 1, bar = 2})
		local _ = ForKeys(scope, data, function(use, key)
			return key, "meta" .. key
		end, function(key, meta)
			destructed[key] = true
			destructed[meta] = true
		end)
		expect(destructed.foo).to.equal(nil)
		expect(destructed.foometa).to.equal(nil)
		expect(destructed.bar).to.equal(nil)
		expect(destructed.barmeta).to.equal(nil)
		doCleanup(scope)
		expect(destructed.foo).to.equal(true)
		expect(destructed.foometa).to.equal(true)
		expect(destructed.bar).to.equal(true)
		expect(destructed.barmeta).to.equal(true)
	end)
end
