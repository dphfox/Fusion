local Package = game:GetService("ReplicatedStorage").Fusion
local PropertyOf = require(Package.Instances.PropertyOf)
local peek = require(Package.State.peek)

return function()
	
	it("should reflect actual property", function()
		local ins = Instance.new("Folder")
		ins.Name = "1"
		
		local name = PropertyOf(ins, "Name")
		
		expect(peek(name)).to.equal("1")
		
		ins.Name = "2"
		
		expect(peek(name)).to.equal("2")
		
	end)
	
end
