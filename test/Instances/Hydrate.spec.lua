local Package = game:GetService("ReplicatedStorage").Fusion
local Hydrate = require(Package.Instances.Hydrate)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	it("should return the instance it was passed", function()
		local scope = {}
		local ins = Instance.new("Folder")
		expect(Hydrate(scope, ins) {}).to.equal(ins)
		doCleanup(scope)
	end)

	it("should apply properties to the instance", function()
		local scope = {}
		local ins = Instance.new("Folder")
		Hydrate(scope, ins) {
			Name = "Jeremy"
		}
		expect(ins.Name).to.equal("Jeremy")
		doCleanup(scope)
	end)
end
