--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local For = require(Fusion.State.For)
local Value = require(Fusion.State.Value)
local Computed = require(Fusion.State.Computed)
local peek = require(Fusion.State.peek)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it

	it("constructs in scopes", function()
		local expect = getfenv().expect
		
		local scope = {}
		local forObject = For(scope, {}, function()
			-- intentionally blank
		end :: any)

		expect(forObject).to.be.a("table")
		expect(forObject.type).to.equal("State")
		expect(forObject.kind).to.equal("For")
		expect(scope[1]).to.equal(forObject.oldestTask)

		doCleanup(scope)
	end)

	it("is destroyable", function()
		local expect = getfenv().expect
		
		local scope = {}
		local forObject = For(scope, {}, function()
			-- intentionally blank
		end :: any)
		
		expect(function()
			doCleanup(forObject)
		end).to.never.throw()
	end)

	it("processes pairs for constant tables", function()
		local expect = getfenv().expect
		
		local scope = {}
		local data = {foo = 1, bar = 2}
		local seen = {}
		local numCalls = 0
		local forObject = For(scope, data, function(scope, inputPair)
			numCalls += 1
			local k, v = peek(inputPair).key, peek(inputPair).value
			seen[k] = v
			return Computed(scope, function(use)
				return {key = string.upper(use(inputPair).key), value = (use(inputPair) :: any).value * 10}
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
		local expect = getfenv().expect
		
		local scope = {}
		local data = Value(scope, {foo = 1, bar = 2} :: {[string]: number})
		local numCalls = 0
		local forObject = For(scope, data, function(scope, inputPair)
			numCalls += 1
			return Computed(scope, function(use)
				return {key = string.upper(use(inputPair).key), value = (use(inputPair) :: any).value * 10}
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
		local expect = getfenv().expect
		
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
		local expect = getfenv().expect
		
		local scope = {}
		local data = {first = 1, second = 2, third = 3}
		local omitThird = Value(scope, false)
		local forObject = For(scope, data, function(scope, inputPair)
			return Computed(scope, function(use)
				if use(inputPair).key == "second" then
					return {key = use(inputPair).key, value = nil}
				elseif use(inputPair).key == "third" and use(omitThird) then
					return {key = use(inputPair).key, value = nil}
				else
					return use(inputPair)
				end
			end)
		end :: any)
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
		local expect = getfenv().expect
		
		local scope = {}
		local data = Value(scope, {"first", "second", "third"})
		local numCalls = 0
		local forObject = For(scope, data, function(scope, inputPair)
			numCalls += 1
			return Computed(scope, function(use)
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
