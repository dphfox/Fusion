local Package = game:GetService("ReplicatedStorage").Fusion
local isAccessible = require(Package.Instances.isAccessible)

return function()
	it("should recognise instances in game", function()
		local instance = Instance.new("Folder")
		instance.Parent = game
		expect(isAccessible(instance)).to.equal(true)
		instance.Parent = nil
	end)

	it("should recognise instances in script", function()
		local instance = Instance.new("Folder")
		instance.Parent = script
		expect(isAccessible(instance)).to.equal(true)
		instance.Parent = nil
	end)

	-- We have to special case this, because our test runner is a LocalScript
	-- with no plugin permissions
	if plugin ~= nil then
		it("should recognise instances in plugin", function()
			local instance = Instance.new("Folder")
			instance.Parent = plugin
			expect(isAccessible(instance)).to.equal(true)
			instance.Parent = nil
		end)
	end

	it("should not recognise instances directly in nil", function()
		local instance = Instance.new("Folder")
		expect(isAccessible(instance)).to.equal(false)
	end)

	it("should not recognise instances indirectly in nil", function()
		local parent = Instance.new("Folder")
		local instance = Instance.new("Folder")
		instance.Parent = parent
		expect(isAccessible(instance)).to.equal(false)
	end)
end