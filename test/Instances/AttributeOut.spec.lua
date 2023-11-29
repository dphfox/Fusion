local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local Attribute = require(Package.Instances.Attribute)
local AttributeOut = require(Package.Instances.AttributeOut)
local Value = require(Package.State.Value)
local peek = require(Package.State.peek)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	it("should update when attributes are changed externally", function()
		local scope = {}
		local attributeValue = Value(scope, nil)
		local child = New(scope, "Folder") {
			[AttributeOut "Foo"] = attributeValue
		}

		expect(peek(attributeValue)).to.equal(nil)
		child:SetAttribute("Foo", "Bar")
		task.wait()
		expect(peek(attributeValue)).to.equal("Bar")
		doCleanup(scope)
	end)

	it("should update when state objects linked update", function()
		local scope = {}
		local attributeValue = Value(scope, "Foo")
		local attributeOutValue = Value(scope)
		local child = New(scope, "Folder") {
			[Attribute "Foo"] = attributeValue,
			[AttributeOut "Foo"] = attributeOutValue
		}
		expect(peek(attributeOutValue)).to.equal("Foo")
		attributeValue:set("Bar")
		task.wait()
		expect(peek(attributeOutValue)).to.equal("Bar")
		doCleanup(scope)
	end)

	it("should work with two-way connections", function()
		local scope = {}
		local attributeValue = Value(scope, "Bar")
		local child = New(scope, "Folder") {
			[Attribute "Foo"] = attributeValue,
			[AttributeOut "Foo"] = attributeValue
		}

		expect(peek(attributeValue)).to.equal("Bar")
		attributeValue:set("Baz")
		task.wait()
		expect(child:GetAttribute("Foo")).to.equal("Baz")
		child:SetAttribute("Foo", "Biff")
		task.wait()
		expect(peek(attributeValue)).to.equal("Biff")
		doCleanup(scope)
	end)
end