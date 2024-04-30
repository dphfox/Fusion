--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local applyInstanceProps = require(Fusion.Instances.applyInstanceProps)
local Value = require(Fusion.State.Value)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it

	it("should assign properties (constant)", function()
		local expect = getfenv().expect

		local scope = {}
		local instance = Instance.new("Folder")
		table.insert(scope, instance)
		applyInstanceProps(
			scope,
			{ Name = "Bob" },
			instance
		)
		expect(instance.Name).to.equal("Bob")
		doCleanup(scope)
	end)

	it("should assign properties (state)", function()
		local expect = getfenv().expect
		
		local scope = {}
		local value = Value(scope, "Bob")
		local instance = Instance.new("Folder")
		table.insert(scope, instance)
		applyInstanceProps(
			scope,
			{ Name = value },
			instance
		)
		expect(instance.Name).to.equal("Bob")

		value:set("Maya")
		expect(instance.Name).to.equal("Maya")
		doCleanup(scope)
	end)

	it("should assign Parent (constant)", function()
		local expect = getfenv().expect
		
		local scope = {}
		local parent = Instance.new("Folder")
		table.insert(scope, parent)
		local instance = Instance.new("Folder")
		table.insert(scope, instance)
		applyInstanceProps(
			scope,
			{ Parent = parent },
			instance
		)
		expect(instance.Parent).to.equal(parent)
		doCleanup(scope)
	end)

	it("should assign Parent (state)", function()
		local expect = getfenv().expect
		
		local scope = {}
		local parent1 = Instance.new("Folder")
		table.insert(scope, parent1)
		local parent2 = Instance.new("Folder")
		table.insert(scope, parent2)
		local value = Value(scope, parent1)
		local instance = Instance.new("Folder")
		table.insert(scope, instance)
		applyInstanceProps(
			scope,
			{ Parent = value },
			instance
		)
		expect(instance.Parent).to.equal(parent1)

		value:set(parent2)
		expect(instance.Parent).to.equal(parent2)
		doCleanup(scope)
	end)

	-- These can't be tested right now because they're non-fatal errors thrown
	-- in a different thread.
	-- TODO: upgrade unit tests to be able to capture those errors.

	-- it("should throw for non-existent properties (constant)", function()
	-- 	local expect = getfenv().expect
		
	-- 	expect(function()
	-- 		local scope = {}
	-- 		local instance = Instance.new("Folder")
	-- 		table.insert(scope, instance)
	-- 		applyInstanceProps(
	-- 			scope,
	-- 			{ NotARealProperty = true },
	-- 			instance
	-- 		)
	-- 		doCleanup(scope)
	-- 	end).to.throw("cannotAssignProperty")
	-- end)

	-- it("should throw for non-existent properties (state)", function()
	-- 	local expect = getfenv().expect
		
	-- 	expect(function()
	-- 		local scope = {}
	-- 		local value = Value(scope, true)
	-- 		local instance = Instance.new("Folder")
	-- 		table.insert(scope, instance)
	-- 		applyInstanceProps(
	-- 			scope,
	-- 			{ NotARealProperty = value },
	-- 			instance
	-- 		)
	-- 		doCleanup(scope)
	-- 	end).to.throw("cannotAssignProperty")
	-- end)

	-- it("should throw for invalid property types (constant)", function()
	-- 	local expect = getfenv().expect
		
	-- 	expect(function()
	-- 		local scope = {}
	-- 		local instance = Instance.new("Folder")
	-- 		table.insert(scope, instance)
	-- 		applyInstanceProps(
	-- 			scope,
	-- 			{ Name = Vector3.new() },
	-- 			instance
	-- 		)
	-- 		doCleanup(scope)
	-- 	end).to.throw("invalidPropertyType")
	-- end)

	-- it("should throw for invalid property types (state)", function()
	-- 	local expect = getfenv().expect
		
	-- 	expect(function()
	-- 		local scope = {}
	-- 		local value = Value(scope, Vector3.new())
	-- 		local instance = Instance.new("Folder")
	-- 		table.insert(scope, instance)
	-- 		applyInstanceProps(
	-- 			scope,
	-- 			{ Name = value },
	-- 			instance
	-- 		)
	-- 		doCleanup(scope)
	-- 	end).to.throw("invalidPropertyType")
	-- end)

	-- it("should throw for invalid Parent types (constant)", function()
	-- 	local expect = getfenv().expect
		
	-- 	expect(function()
	-- 		local scope = {}
	-- 		local instance = Instance.new("Folder")
	-- 		table.insert(scope, instance)
	-- 		applyInstanceProps(
	-- 			scope,
	-- 			{ Parent = Vector3.new() },
	-- 			instance
	-- 		)
	-- 		doCleanup(scope)
	-- 	end).to.throw("invalidPropertyType")
	-- end)

	-- it("should throw for invalid Parent types (state)", function()
	-- 	local expect = getfenv().expect
		
	-- 	expect(function()
	-- 		local scope = {}
	-- 		local value = Value(scope, Vector3.new()) 
	-- 		local instance = Instance.new("Folder")
	-- 		table.insert(scope, instance)
	-- 		applyInstanceProps(
	-- 			scope,
	-- 			{ Parent = value },
	-- 			instance
	-- 		)
	-- 		doCleanup(scope)
	-- 	end).to.throw("invalidPropertyType")
	-- end)

	it("should throw for unrecognised keys in the property table", function()
		local expect = getfenv().expect
		
		expect(function()
			local scope = {}
			local instance = Instance.new("Folder")
			table.insert(scope, instance)
			applyInstanceProps(
				scope,
				{ [2 :: any] = true }, 
				instance
			)
			doCleanup(scope)
		end).to.throw("unrecognisedPropertyKey")
	end)
end
