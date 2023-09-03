local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local Out = require(Package.Instances.Out)
local Value = require(Package.State.Value)
local peek = require(Package.State.peek)

return function()
	it("should reflect external property changes", function()
		local outValue = Value()

		local child = New "Folder" {
			[Out "Name"] = outValue
		}
		expect(peek(outValue)).to.equal("Folder")

		child.Name = "Mary"
		task.wait()
		expect(peek(outValue)).to.equal("Mary")
	end)

	it("should reflect property changes from bound state", function()
		local outValue = Value()
		local inValue = Value("Gabriel")

		local child = New "Folder" {
			Name = inValue,
			[Out "Name"] = outValue
		}
		expect(peek(outValue)).to.equal("Gabriel")

		inValue:set("Joseph")
		task.wait()
		expect(peek(outValue)).to.equal("Joseph")
	end)

	it("should support two-way data binding", function()
		local twoWayValue = Value("Gabriel")

		local child = New "Folder" {
			Name = twoWayValue,
			[Out "Name"] = twoWayValue
		}
		expect(peek(twoWayValue)).to.equal("Gabriel")

		twoWayValue:set("Joseph")
		task.wait()
		expect(child.Name).to.equal("Joseph")

		child.Name = "Elias"
		task.wait()
		expect(peek(twoWayValue)).to.equal("Elias")
	end)
end
