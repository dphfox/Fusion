local Package = game:GetService("ReplicatedStorage").Fusion
local applyInstanceProps = require(Package.Instances.applyInstanceProps)
local Value = require(Package.State.Value)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	it("should assign properties (constant)", function()
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
		task.wait() -- property changes are deferred

		expect(instance.Name).to.equal("Maya")
		doCleanup(scope)
	end)

	it("should assign Parent (constant)", function()
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
		task.wait() -- property changes are deferred

		expect(instance.Parent).to.equal(parent2)
		doCleanup(scope)
	end)

	it("should throw for non-existent properties (constant)", function()
		expect(function()
			local scope = {}
			local instance = Instance.new("Folder")
			table.insert(scope, instance)
			applyInstanceProps(
				scope,
				{ NotARealProperty = true },
				instance
			)
			doCleanup(scope)
		end).to.throw("cannotAssignProperty")
	end)

	it("should throw for non-existent properties (state)", function()
		expect(function()
			local scope = {}
			local value = Value(scope, true)
			local instance = Instance.new("Folder")
			table.insert(scope, instance)
			applyInstanceProps(
				scope,
				{ NotARealProperty = value },
				instance
			)
			doCleanup(scope)
		end).to.throw("cannotAssignProperty")
	end)

	it("should throw for invalid property types (constant)", function()
		expect(function()
			local scope = {}
			local instance = Instance.new("Folder")
			table.insert(scope, instance)
			applyInstanceProps(
				scope,
				{ Name = Vector3.new() },
				instance
			)
			doCleanup(scope)
		end).to.throw("invalidPropertyType")
	end)

	it("should throw for invalid property types (state)", function()
		expect(function()
			local scope = {}
			local value = Value(scope, Vector3.new())
			local instance = Instance.new("Folder")
			table.insert(scope, instance)
			applyInstanceProps(
				scope,
				{ Name = value },
				instance
			)
			doCleanup(scope)
		end).to.throw("invalidPropertyType")
	end)

	it("should throw for invalid Parent types (constant)", function()
		expect(function()
			local scope = {}
			local instance = Instance.new("Folder")
			table.insert(scope, instance)
			applyInstanceProps(
				scope,
				{ Parent = Vector3.new() },
				instance
			)
			doCleanup(scope)
		end).to.throw("invalidPropertyType")
	end)

	it("should throw for invalid Parent types (state)", function()
		expect(function()
			local scope = {}
			local value = Value(scope, Vector3.new()) 
			local instance = Instance.new("Folder")
			table.insert(scope, instance)
			applyInstanceProps(
				scope,
				{ Parent = value },
				instance
			)
			doCleanup(scope)
		end).to.throw("invalidPropertyType")
	end)

	it("should throw for unrecognised keys in the property table", function()
		expect(function()
			local scope = {}
			local instance = Instance.new("Folder")
			table.insert(scope, instance)
			applyInstanceProps(
				scope,
				{ [2] = true }, 
				instance
			)
			doCleanup(scope)
		end).to.throw("unrecognisedPropertyKey")
	end)

	it("should defer property changes", function()
		local scope = {}
		local value = Value(scope, "Bob")
		local instance = Instance.new("Folder")
		table.insert(scope, instance)
		applyInstanceProps(
			scope,
			{ Name = value },
			instance
		)
		value:set("Maya")

		expect(instance.Name).to.equal("Bob")
		task.wait()
		expect(instance.Name).to.equal("Maya")
		doCleanup(scope)
	end)

	it("should defer Parent changes", function()
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
		value:set(parent2)

		expect(instance.Parent).to.equal(parent1)
		task.wait()
		expect(instance.Parent).to.equal(parent2)
		doCleanup(scope)
	end)
end
