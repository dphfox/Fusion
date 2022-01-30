local Package = game:GetService("ReplicatedStorage").Fusion
local semiWeakRef = require(Package.Instances.semiWeakRef)

return function()
	it("should return a correct reference", function()
		local instance = Instance.new("Folder")
		local ref = semiWeakRef(instance)
		expect(ref).to.be.a("table")
		expect(ref.type).to.equal("SemiWeakRef")
		expect(ref.instance).to.equal(instance)
	end)

	it("should be strong when the instance is accessible", function()
		local instance = Instance.new("Folder")
		instance.Parent = game
		local ref = semiWeakRef(instance)
		task.wait()
		expect(getmetatable(ref).__mode).to.equal("")
		instance.Parent = nil
	end)

	it("should be weak when the instance is not accessible", function()
		local instance = Instance.new("Folder")
		local ref = semiWeakRef(instance)
		task.wait()
		expect(getmetatable(ref).__mode).to.equal("v")
	end)

	it("should switch between strong and weak dynamically", function()
		local instance = Instance.new("Folder")
		instance.Parent = game
		local ref = semiWeakRef(instance)
		task.wait()
		expect(getmetatable(ref).__mode).to.equal("")
		instance.Parent = nil
		task.wait()
		expect(getmetatable(ref).__mode).to.equal("v")
		instance.Parent = game
		task.wait()
		expect(getmetatable(ref).__mode).to.equal("")
		instance.Parent = nil
	end)
end