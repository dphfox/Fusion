local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local Ref = require(Package.Instances.Ref)
local Value = require(Package.State.Value)
local peek = require(Package.State.peek)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	it("should set State objects passed as [Ref]", function()
		local scope = {}
		local refValue = Value(scope, nil)

		local child = New(scope, "Folder") {
			[Ref] = refValue
		}

		expect(peek(refValue)).to.equal(child)
		doCleanup(scope)
	end)
end
