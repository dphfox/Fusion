local Package = game:GetService("ReplicatedStorage").Fusion
local applyInstanceProps = require(Package.Instances.applyInstanceProps)
local Value = require(Package.State.Value)

return function()
	it("should assign properties (constant)", function()
		local instance = Instance.new("Folder")
		applyInstanceProps({
			Name = "Bob",
		}, instance)
		expect(instance.Name).to.equal("Bob")
	end)

	it("should assign properties (state)", function()
		local value = Value("Bob")
		local instance = Instance.new("Folder")
		applyInstanceProps({
			Name = value,
		}, instance)
		expect(instance.Name).to.equal("Bob")

		value:set("Maya")
		task.wait() -- property changes are deferred

		expect(instance.Name).to.equal("Maya")
	end)

	it("should assign Parent (constant)", function()
		local parent = Instance.new("Folder")
		local instance = Instance.new("Folder")
		applyInstanceProps({
			Parent = parent,
		}, instance)
		expect(instance.Parent).to.equal(parent)
	end)

	it("should assign Parent (state)", function()
		local parent1 = Instance.new("Folder")
		local parent2 = Instance.new("Folder")
		local value = Value(parent1)
		local instance = Instance.new("Folder")
		applyInstanceProps({
			Parent = value,
		}, instance)
		expect(instance.Parent).to.equal(parent1)

		value:set(parent2)
		task.wait() -- property changes are deferred

		expect(instance.Parent).to.equal(parent2)
	end)

	it("should throw for non-existent properties (constant)", function()
		expect(function()
			local instance = Instance.new("Folder")
			applyInstanceProps({
				NotARealProperty = true,
			}, instance)
		end).to.throw("cannotAssignProperty")
	end)

	it("should throw for non-existent properties (state)", function()
		expect(function()
			local instance = Instance.new("Folder")
			applyInstanceProps({
				NotARealProperty = Value(true),
			}, instance)
		end).to.throw("cannotAssignProperty")
	end)

	it("should throw for invalid property types (constant)", function()
		expect(function()
			local instance = Instance.new("Folder")
			applyInstanceProps({
				Name = Vector3.new(),
			}, instance)
		end).to.throw("invalidPropertyType")
	end)

	it("should throw for invalid property types (state)", function()
		expect(function()
			local instance = Instance.new("Folder")
			applyInstanceProps({
				Name = Value(Vector3.new()),
			}, instance)
		end).to.throw("invalidPropertyType")
	end)

	it("should throw for invalid Parent types (constant)", function()
		expect(function()
			local instance = Instance.new("Folder")
			applyInstanceProps({
				Parent = Vector3.new(),
			}, instance)
		end).to.throw("invalidPropertyType")
	end)

	it("should throw for invalid Parent types (state)", function()
		expect(function()
			local instance = Instance.new("Folder")
			applyInstanceProps({
				Parent = Value(Vector3.new()),
			}, instance)
		end).to.throw("invalidPropertyType")
	end)

	it("should throw for unrecognised keys in the property table", function()
		expect(function()
			local instance = Instance.new("Folder")
			applyInstanceProps({
				[2] = true,
			}, instance)
		end).to.throw("unrecognisedPropertyKey")
	end)

	it("should defer property changes", function()
		local value = Value("Bob")
		local instance = Instance.new("Folder")
		applyInstanceProps({
			Name = value,
		}, instance)
		value:set("Maya")

		expect(instance.Name).to.equal("Bob")
		task.wait()
		expect(instance.Name).to.equal("Maya")
	end)

	it("should defer Parent changes", function()
		local parent1 = Instance.new("Folder")
		local parent2 = Instance.new("Folder")
		local value = Value(parent1)
		local instance = Instance.new("Folder")
		applyInstanceProps({
			Parent = value,
		}, instance)
		value:set(parent2)

		expect(instance.Parent).to.equal(parent1)
		task.wait()
		expect(instance.Parent).to.equal(parent2)
	end)
end
