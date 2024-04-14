local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local defaultProps = require(Package.Instances.defaultProps)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	it("should create a new instance", function()
		local scope = {}
		local ins = New (scope, "Frame") {}
		expect(typeof(ins) == "Instance").to.be.ok()
		expect(ins:IsA("Frame")).to.be.ok()
	end)

	it("should throw for non-existent class types", function()
		expect(function()
			local scope = {}
			New (scope, "This is not a valid class type") {}
			doCleanup(scope)
		end).to.throw("cannotCreateClass")
	end)

	it("should apply 'sensible default' properties", function()
		for className, defaults in pairs(defaultProps) do
			local scope = {}
			local ins = New (scope, className) {}
			for propName, propValue in pairs(defaults) do
				expect(ins[propName]).to.equal(propValue)
			end
			doCleanup(scope)
		end
	end)
end
