--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion
local scoped = require(Fusion.Memory.scoped)
local doCleanup = require(Fusion.Memory.doCleanup)
local insert = require(Fusion.Memory.insert)

return function()
	local it = getfenv().it

	it("should accept zero tasks", function()
		local expect = getfenv().expect

		local scope = scoped()
		insert(scope)

		expect(#scope).to.equal(0)
	end)

	it("should accept single tasks", function()
		local expect = getfenv().expect

		local isDestroyed = false
		local scope = scoped()
		insert(scope, function()
			isDestroyed = true
		end)

		expect(#scope).to.equal(1)
		doCleanup(scope)

		expect(isDestroyed).to.equal(true)
	end)

	it("should accept multiple tasks", function()
		local expect = getfenv().expect

		local counter = 0
		local scope = scoped()

		insert(scope, function()
			counter += 1
		end)
		insert(scope, function()
			counter += 1
		end)
		insert(scope, {
  		function()
  			counter += 1
  		end
		})

		expect(#scope).to.equal(3)
		doCleanup(scope)
		expect(counter).to.equal(3)
	end)

	it("should return the given tasks", function()
		local expect = getfenv().expect

		local counter = 0
		local function onDestroy()
			counter += 1
		end
		local function onDestroy2()
			counter += 2
		end
		local scope = scoped()

		local returnedDestroy, returnedDestroy2 = insert(scope, onDestroy, onDestroy2)
		expect(returnedDestroy).to.equal(onDestroy)
		expect(returnedDestroy2).to.equal(onDestroy2)
		expect(#scope).to.equal(2)
		doCleanup(scope)
		expect(counter).to.equal(3)
	end)
end
