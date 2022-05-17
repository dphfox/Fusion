local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local Ref = require(Package.Instances.Ref)
local Value = require(Package.Core.Value)

local waitForGC = require(script.Parent.Parent.Utility.waitForGC)

return function()
	it("should set State objects passed as [Ref]", function()
		local refValue = Value()

		local child = New "Folder" {
			[Ref] = refValue
		}

		expect(refValue:get()).to.equal(child)
	end)

	it("should not inhibit garbage collection", function()
		local ref = setmetatable({}, {__mode = "v"})
		do
			local refValue = Value()
			ref[1] = New "Folder" {
				[Ref] = refValue
			}
			refValue:set(nil)
		end

		waitForGC()
		-- Wait twice in case the Value keeps the instance an extra cycle
		waitForGC()

		expect(ref[1]).to.equal(nil)
	end)
end