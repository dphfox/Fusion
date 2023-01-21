local Package = game:GetService("ReplicatedStorage").Fusion

local New = require(Package.Instances.New)
local Attribute = require(Package.Instances.Attribute)
local Value = require(Package.State.Value)

return function()
	it("should assign constant attributes to objects", function()
		local child = New "Folder" {
            [Attribute "Test"] = "AttributeOne"
        }

        expect(child:GetAttribute("Test")).to.equal("AttributeOne")
	end)

    it("should bind attributes to state objects", function()
        local attributeValue = Value("AttributeOne")
		local child = New "Folder" {
            [Attribute "Test"] = attributeValue
        }

        expect(child:GetAttribute("Test")).to.equal("AttributeOne")
        attributeValue:set("AttributeTwo")
        task.wait()
        expect(child:GetAttribute("Test")).to.equal("AttributeTwo")
	end)
end
