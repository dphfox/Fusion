local Package = game:GetService("ReplicatedStorage").Fusion
local OnEvent = require(Package.Instances.OnEvent)

return function()
	it("should construct the correct symbols when called", function()
		local symbol = OnEvent("Foo")

		expect(symbol).to.be.a("table")
		expect(symbol.type).to.equal("Symbol")
		expect(symbol.name).to.equal("OnEvent")
		expect(symbol.key).to.equal("Foo")
	end)
end