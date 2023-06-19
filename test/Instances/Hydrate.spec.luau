local Package = game:GetService("ReplicatedStorage").Fusion
local Hydrate = require(Package.Instances.Hydrate)

return function()
	it("should return the instance it was passed", function()
		local ins = Instance.new("Folder")

		expect(Hydrate(ins) {}).to.equal(ins)
	end)

	it("should apply properties to the instance", function()
		local ins = Instance.new("Folder")

		Hydrate(ins) {
			Name = "Jeremy"
		}

		expect(ins.Name).to.equal("Jeremy")
	end)
end
