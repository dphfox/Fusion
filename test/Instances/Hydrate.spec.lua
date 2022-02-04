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

	it("should not inhibit garbage collection", function()
		local ref = setmetatable({}, {__mode = "v"})
		do
			ref[1] = Hydrate(Instance.new("Folder")) {}
		end

		local startTime = os.clock()
		repeat
			task.wait()
		until ref[1] == nil or os.clock() > startTime + 5
		expect(ref[1]).to.equal(nil)
	end)
end