local Package = game:GetService("ReplicatedStorage").Fusion
local OnChange = require(Package.Instances.OnChange)

return function()
	it("should construct the correct symbols when called", function()
		local symbol = OnChange("Foo")

		expect(symbol).to.be.a("table")
		expect(symbol.type).to.equal("Symbol")
		expect(symbol.name).to.equal("OnChange")
		expect(symbol.key).to.equal("Foo")
	end)
end