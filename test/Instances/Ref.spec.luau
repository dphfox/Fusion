local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local Ref = require(Package.Instances.Ref)
local Value = require(Package.State.Value)
local peek = require(Package.State.peek)

return function()
	it("should set State objects passed as [Ref]", function()
		local refValue = Value()

		local child = New "Folder" {
			[Ref] = refValue
		}

		expect(peek(refValue)).to.equal(child)
	end)
end
