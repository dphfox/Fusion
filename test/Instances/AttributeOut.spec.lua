local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local Attribute = require(Package.Instances.Attribute)
local AttributeOut = require(Package.Instances.AttributeOut)
local Value = require(Package.State.Value)

return function ()
    it("should update when attributes are changed externally", function()
		local attributeValue = Value()
		local child = New "Folder" {
			[AttributeOut "Foo"] = attributeValue
		}

		expect(attributeValue:get()).to.equal(nil)
		child:SetAttribute("Foo", "Bar")
		task.wait()
		expect(attributeValue:get()).to.equal("Bar")
	end)

    it("should update when state objects linked update", function()
		local attributeValue = Value("Foo")
        local attributeOutValue = Value()

		local child = New "Folder" {
			[Attribute "Foo"] = attributeValue,
			[AttributeOut "Foo"] = attributeOutValue
		}

		expect(attributeOutValue:get()).to.equal("Foo")
		attributeValue:set("Bar")
		task.wait()
		expect(attributeOutValue:get()).to.equal("Bar")
    end)

    it("should work with two-way connections", function()
		local attributeValue = Value("Bar")
		local child = New "Folder" {
			[Attribute "Foo"] = attributeValue,
			[AttributeOut "Foo"] = attributeValue
		}

		expect(attributeValue:get()).to.equal("Bar")
		attributeValue:set("Baz")
		task.wait()

		expect(child:GetAttribute("Foo")).to.equal("Baz")
		child:SetAttribute("Foo", "Biff")
		task.wait()

		expect(attributeValue:get()).to.equal("Biff")
	end)
end