local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local Out = require(Package.Instances.Out)
local Value = require(Package.Core.Value)

local waitForGC = require(script.Parent.Parent.Utility.waitForGC)

return function()
	it("should reflect external property changes", function()
		local outValue = Value()

		local child = New "Folder" {
			[Out "Name"] = outValue
		}
		expect(outValue:get()).to.equal("Folder")

		child.Name = "Mary"
		task.wait()
		expect(outValue:get()).to.equal("Mary")
	end)

	it("should reflect property changes from bound state", function()
		local outValue = Value()
		local inValue = Value("Gabriel")

		local child = New "Folder" {
			Name = inValue,
			[Out "Name"] = outValue
		}
		expect(outValue:get()).to.equal("Gabriel")

		inValue:set("Joseph")
		task.wait()
		expect(outValue:get()).to.equal("Joseph")
	end)

	it("should support two-way data binding", function()
		local twoWayValue = Value("Gabriel")

		local child = New "Folder" {
			Name = twoWayValue,
			[Out "Name"] = twoWayValue
		}
		expect(twoWayValue:get()).to.equal("Gabriel")

		twoWayValue:set("Joseph")
		task.wait()
		expect(child.Name).to.equal("Joseph")

		child.Name = "Elias"
		task.wait()
		expect(twoWayValue:get()).to.equal("Elias")
	end)

	it("should not inhibit garbage collection", function()
		local ref = setmetatable({}, {__mode = "v"})
		do
			local outValue = Value()
			ref[1] = New "Folder" {
				[Out "Name"] = outValue
			}
		end

		waitForGC()

		expect(ref[1]).to.equal(nil)
	end)
end