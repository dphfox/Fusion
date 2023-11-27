local Package = game:GetService("ReplicatedStorage").Fusion
local For = require(Package.State.For)
local Value = require(Package.State.Value)
local Computed = require(Package.State.Computed)
local peek = require(Package.State.peek)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	it("constructs in scopes", function()
		local scope = {}
		local genericFor = For(scope, {}, function()
			-- intentionally blank
		end)

		expect(genericFor).to.be.a("table")
		expect(genericFor.type).to.equal("State")
		expect(genericFor.kind).to.equal("For")
		expect(scope[1]).to.equal(genericFor)

		doCleanup(scope)
	end)

	it("is destroyable", function()
		local scope = {}
		local genericFor = For(scope, {}, function()
			-- intentionally blank
		end)
		
		expect(function()
			genericFor:destroy()
		end).to.never.throw()
	end)

	it("processes pairs for constant tables", function()
		local scope = {}
		local data = {foo = 1, bar = 2}
		local seen = {}
		local numCalls = 0
		local genericFor = For(scope, data, function(scope, inputKey, inputValue)
			numCalls += 1
			local k, v = peek(inputKey), peek(inputValue)
			seen[k] = v
			local outputKey = Computed(scope, function(use)
				return string.upper(use(inputKey))
			end)
			local outputValue = Computed(scope, function(use)
				return use(inputValue) * 10
			end)
			return outputKey, outputValue
		end)
		expect(numCalls).to.equal(2)
		expect(seen.foo).to.equal(1)
		expect(seen.bar).to.equal(2)

		expect(peek(genericFor)).to.be.a("table")
		expect(peek(genericFor).FOO).to.equal(10)
		expect(peek(genericFor).BAR).to.equal(20)
		doCleanup(scope)
	end)

	it("processes pairs for state tables", function()
		local scope = {}
		local data = Value(scope, {foo = 1, bar = 2})
		local numCalls = 0
		local genericFor = For(scope, data, function(scope, inputKey, inputValue)
			numCalls += 1
			local outputKey = Computed(scope, function(use)
				return string.upper(use(inputKey))
			end)
			local outputValue = Computed(scope, function(use)
				return use(inputValue) * 10
			end)
			return outputKey, outputValue
		end)
		expect(numCalls).to.equal(2)

		expect(peek(genericFor)).to.be.a("table")
		expect(peek(genericFor).FOO).to.equal(10)
		expect(peek(genericFor).BAR).to.equal(20)

		data:set({frob = 3, garb = 4})

		expect(numCalls).to.equal(2)
		expect(peek(genericFor).FOO).to.equal(nil)
		expect(peek(genericFor).BAR).to.equal(nil)
		expect(peek(genericFor).FROB).to.equal(30)
		expect(peek(genericFor).GARB).to.equal(40)

		data:set({frob = 5, garb = 6, baz = 7})

		expect(numCalls).to.equal(3)
		expect(peek(genericFor).FROB).to.equal(50)
		expect(peek(genericFor).GARB).to.equal(60)
		expect(peek(genericFor).BAZ).to.equal(70)

		data:set({garb = 6, baz = 7})

		expect(numCalls).to.equal(3)
		expect(peek(genericFor).FROB).to.equal(nil)
		expect(peek(genericFor).GARB).to.equal(60)
		expect(peek(genericFor).BAZ).to.equal(70)

		data:set({})

		expect(numCalls).to.equal(3)
		expect(peek(genericFor).GARB).to.equal(nil)
		expect(peek(genericFor).BAZ).to.equal(nil)
		
		doCleanup(scope)
	end)

	-- itSKIP("rejects key collisions", function()
	-- 	expect(function()
	-- 		local scope = {}
	-- 		local data = {foo = 1, bar = 2}
	-- 		local _ = ForKeys(scope, data, function(use, key)
	-- 			return "samuel"
	-- 		end)
	-- 		doCleanup(scope)
	-- 	end).to.throw("forKeysKeyCollision")
	-- end)

	-- itSKIP("preserves value on error", function()
	-- 	local scope = {}
	-- 	local data = {foo = 1, bar = 2}
	-- 	local suffix = Value(scope, "first")
	-- 	local forkeys = ForKeys(scope, data, function(use, key)
	-- 		assert(use(suffix) ~= "second", "This is an intentional error from a unit test")
	-- 		return key .. use(suffix)
	-- 	end)
	-- 	expect(peek(forkeys).foofirst).to.equal(1)
	-- 	expect(peek(forkeys).barfirst).to.equal(2)
	-- 	suffix:set("second") -- will invoke the error
	-- 	expect(peek(forkeys).foofirst).to.equal(1)
	-- 	expect(peek(forkeys).barfirst).to.equal(2)
	-- 	expect(peek(forkeys).foosecond).to.equal(nil)
	-- 	expect(peek(forkeys).barsecond).to.equal(nil)
	-- 	suffix:set("third")
	-- 	expect(peek(forkeys).foofirst).to.equal(nil)
	-- 	expect(peek(forkeys).barfirst).to.equal(nil)
	-- 	expect(peek(forkeys).foosecond).to.equal(nil)
	-- 	expect(peek(forkeys).barsecond).to.equal(nil)
	-- 	expect(peek(forkeys).foothird).to.equal(1)
	-- 	expect(peek(forkeys).barthird).to.equal(2)
	-- 	doCleanup(scope)
	-- end)

	-- itSKIP("doesn't call destructor on creation", function()
	-- 	local scope = {}
	-- 	local destructed = {}
	-- 	local data = Value(scope, {foo = 1, bar = 2})
	-- 	local _ = ForKeys(scope, data, function(use, key)
	-- 		return key, "meta" .. key
	-- 	end, function(key, meta)
	-- 		destructed[key] = true
	-- 		destructed[meta] = true
	-- 	end)
	-- 	expect(destructed.foo).to.equal(nil)
	-- 	expect(destructed.metafoo).to.equal(nil)
	-- 	expect(destructed.bar).to.equal(nil)
	-- 	expect(destructed.metabar).to.equal(nil)
	-- 	doCleanup(scope)
	-- end)

	-- itSKIP("calls destructor on update", function()
	-- 	local scope = {}
	-- 	local destructed = {}
	-- 	local data = Value(scope, {foo = 1, bar = 2})
	-- 	local _ = ForKeys(scope, data, function(use, key)
	-- 		return key, "meta" .. key
	-- 	end, function(key, meta)
	-- 		destructed[key] = true
	-- 		destructed[meta] = true
	-- 	end)
	-- 	data:set({foo = 100, baz = 3})
	-- 	expect(destructed.foo).to.equal(nil)
	-- 	expect(destructed.metafoo).to.equal(nil)
	-- 	expect(destructed.bar).to.equal(true)
	-- 	expect(destructed.metabar).to.equal(true)
	-- 	doCleanup(scope)
	-- end)

	-- itSKIP("calls destructor on destroy", function()
	-- 	local scope = {}
	-- 	local destructed = {}
	-- 	local data = Value(scope, {foo = 1, bar = 2})
	-- 	local _ = ForKeys(scope, data, function(use, key)
	-- 		return key, "meta" .. key
	-- 	end, function(key, meta)
	-- 		destructed[key] = true
	-- 		destructed[meta] = true
	-- 	end)
	-- 	expect(destructed.foo).to.equal(nil)
	-- 	expect(destructed.metafoo).to.equal(nil)
	-- 	expect(destructed.bar).to.equal(nil)
	-- 	expect(destructed.metabar).to.equal(nil)
	-- 	doCleanup(scope)
	-- 	expect(destructed.foo).to.equal(true)
	-- 	expect(destructed.metafoo).to.equal(true)
	-- 	expect(destructed.bar).to.equal(true)
	-- 	expect(destructed.metabar).to.equal(true)
	-- end)
end
