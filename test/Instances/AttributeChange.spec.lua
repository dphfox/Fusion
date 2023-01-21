local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local Attribute = require(Package.Instances.Attribute)
local AttributeChange = require(Package.Instances.AttributeChange)
local Value = require(Package.State.Value)

return function()
	it("should run when an attribute is changed", function()
		local attribute = ""

        local child = New "Folder" {
            [Attribute "Test"] = "AttributeOne",
			[AttributeChange "Test"] = function(newValue)
				attribute = newValue
			end
		}
		expect(attribute).to.equal("AttributeOne")
		child:SetAttribute("Test", "AttributeTwo")
		task.wait()
		expect(attribute).to.equal("AttributeTwo")
	end)

	it("should update when a state value corresponding to it changes", function()
		local attribute = Value("AttributeOne")
		local updated = Value("")

        local child = New "Folder" {
            [Attribute "Test"] = attribute,
			[AttributeChange "Test"] = function(newValue)
				updated:set(newValue)
			end
		}
		expect(updated:get()).to.equal("AttributeOne")
		attribute:set("AttributeTwo")
		task.wait()
		expect(updated:get()).to.equal("AttributeTwo")
	end)
end
