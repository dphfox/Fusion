local Package = game:GetService("ReplicatedStorage").Fusion
local Hydrate = require(Package.Instances.Hydrate)

local waitForGC = require(script.Parent.Parent.Utility.waitForGC)

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

	it("should not inhibit garbage collection", function()
		local ref = setmetatable({}, {__mode = "v"})
		do
			ref[1] = Hydrate(Instance.new("Folder")) {}
		end

		waitForGC()

		expect(ref[1]).to.equal(nil)
	end)
end