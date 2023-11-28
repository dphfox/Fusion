local Package = game:GetService("ReplicatedStorage").Fusion
local For = require(Package.State.For)
local Value = require(Package.State.Value)
local Computed = require(Package.State.Computed)
local peek = require(Package.State.peek)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	it("constructs in scopes", function()
		local scope = {}
		local forObject = For(scope, {}, function()
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
		local forObject = For(scope, {}, function()
			-- intentionally blank
		end)
		
		expect(function()
			forObject:destroy()
		end).to.never.throw()
	end)

	it("processes pairs for constant tables", function()
		local scope = {}
		local data = {foo = 1, bar = 2}
		local seen = {}
		local numCalls = 0
		local forObject = For(scope, data, function(scope, inputPair)
			numCalls += 1
			local k, v = peek(inputPair).key, peek(inputPair).value
			seen[k] = v
			return Computed(scope, function(_, use)
				return {key = string.upper(use(inputPair).key), value = use(inputPair).value * 10}
			end)
		end)
		expect(numCalls).to.equal(2)
		expect(seen.foo).to.equal(1)
		expect(seen.bar).to.equal(2)

		expect(peek(forObject)).to.be.a("table")
		expect(peek(forObject).FOO).to.equal(10)
		expect(peek(forObject).BAR).to.equal(20)
		doCleanup(scope)
	end)

	it("processes pairs for state tables", function()
		local scope = {}
		local data = Value(scope, {foo = 1, bar = 2})
		local numCalls = 0
		local forObject = For(scope, data, function(scope, inputPair)
			numCalls += 1
			return Computed(scope, function(_, use)
				return {key = string.upper(use(inputPair).key), value = use(inputPair).value * 10}
			end)
		end)
		expect(numCalls).to.equal(2)

		expect(peek(forObject)).to.be.a("table")
		expect(peek(forObject).FOO).to.equal(10)
		expect(peek(forObject).BAR).to.equal(20)

		data:set({frob = 3, garb = 4})

		expect(numCalls).to.equal(2)
		expect(peek(forObject).FOO).to.equal(nil)
		expect(peek(forObject).BAR).to.equal(nil)
		expect(peek(forObject).FROB).to.equal(30)
		expect(peek(forObject).GARB).to.equal(40)

		data:set({frob = 5, garb = 6, baz = 7})

		expect(numCalls).to.equal(3)
		expect(peek(forObject).FROB).to.equal(50)
		expect(peek(forObject).GARB).to.equal(60)
		expect(peek(forObject).BAZ).to.equal(70)

		data:set({garb = 6, baz = 7})

		expect(numCalls).to.equal(3)
		expect(peek(forObject).FROB).to.equal(nil)
		expect(peek(forObject).GARB).to.equal(60)
		expect(peek(forObject).BAZ).to.equal(70)

		data:set({})

		expect(numCalls).to.equal(3)
		expect(peek(forObject).GARB).to.equal(nil)
		expect(peek(forObject).BAZ).to.equal(nil)
		
		doCleanup(scope)
	end)

	it("omits pairs that error", function()
		local scope = {}
		local data = {first = 1, second = 2, third = 3}
		local forObject = For(scope, data, function(scope, inputPair)
			assert(peek(inputPair).key ~= "second", "This is an intentional error from a unit test")
			return inputPair
		end)
		expect(peek(forObject).first).to.equal(1)
		expect(peek(forObject).second).to.equal(nil)
		expect(peek(forObject).third).to.equal(3)
		doCleanup(scope)
	end)

	it("omits pairs when their value is nil", function()
		local scope = {}
		local data = {first = 1, second = 2, third = 3}
		local omitThird = Value(scope, false)
		local forObject = For(scope, data, function(scope, inputPair)
			return Computed(scope, function(_, use)
				if use(inputPair).key == "second" then
					return {key = use(inputPair).key, value = nil}
				elseif use(inputPair).key == "third" and use(omitThird) then
					return {key = use(inputPair).key, value = nil}
				else
					return use(inputPair)
				end
			end)
		end)
		expect(peek(forObject).first).to.equal(1)
		expect(peek(forObject).second).to.equal(nil)
		expect(peek(forObject).third).to.equal(3)
		omitThird:set(true)
		expect(peek(forObject).first).to.equal(1)
		expect(peek(forObject).second).to.equal(nil)
		expect(peek(forObject).third).to.equal(nil)
		omitThird:set(false)
		expect(peek(forObject).first).to.equal(1)
		expect(peek(forObject).second).to.equal(nil)
		expect(peek(forObject).third).to.equal(3)
		doCleanup(scope)
	end)

	it("allows values to roam when their key is nil", function()
		local scope = {}
		local data = Value(scope, {"first", "second", "third"})
		local numCalls = 0
		local forObject = For(scope, data, function(scope, inputPair)
			numCalls += 1
			return Computed(scope, function(_, use)
				return {key = nil, value = use(inputPair).value}
			end)
		end)
		expect(table.find(peek(forObject), "first")).to.be.ok()
		expect(table.find(peek(forObject), "second")).to.be.ok()
		expect(table.find(peek(forObject), "third")).to.be.ok()
		expect(numCalls).to.equal(3)
		data:set({"third", "first", "second"})
		expect(table.find(peek(forObject), "first")).to.be.ok()
		expect(table.find(peek(forObject), "second")).to.be.ok()
		expect(table.find(peek(forObject), "third")).to.be.ok()
		expect(numCalls).to.equal(3)
		data:set({"second", "first"})
		expect(table.find(peek(forObject), "first")).to.be.ok()
		expect(table.find(peek(forObject), "second")).to.be.ok()
		expect(table.find(peek(forObject), "third")).to.never.be.ok()
		expect(numCalls).to.equal(3)
		data:set({"first"})
		expect(table.find(peek(forObject), "first")).to.be.ok()
		expect(table.find(peek(forObject), "second")).to.never.be.ok()
		expect(numCalls).to.equal(3)
		doCleanup(scope)
	end)
end
