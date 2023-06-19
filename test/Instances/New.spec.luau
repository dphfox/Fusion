local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local defaultProps = require(Package.Instances.defaultProps)

local waitForGC = require(script.Parent.Parent.Utility.waitForGC)

return function()
	it("should create a new instance", function()
		local ins = New "Frame" {}

		expect(typeof(ins) == "Instance").to.be.ok()
		expect(ins:IsA("Frame")).to.be.ok()
	end)

	it("should throw for non-existent class types", function()
		expect(function()
			New "This is not a valid class type" {}
		end).to.throw("cannotCreateClass")
	end)

	it("should apply 'sensible default' properties", function()
		for className, defaults in pairs(defaultProps) do
			local ins = New (className) {}

			for propName, propValue in pairs(defaults) do
				expect(ins[propName]).to.equal(propValue)
			end
		end
	end)
end
