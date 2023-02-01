local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local Ref = require(Package.Instances.Ref)
local Value = require(Package.State.Value)

return function()
	it("should set State objects passed as [Ref]", function()
		local refValue = Value()

		local child = New "Folder" {
			[Ref] = refValue
		}

		expect(refValue:get()).to.equal(child)
	end)
end
