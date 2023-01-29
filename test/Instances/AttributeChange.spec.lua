local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local Attribute = require(Package.Instances.Attribute)
local AttributeChange = require(Package.Instances.AttributeChange)
local Value = require(Package.State.Value)

return function()
	it("should connect attribute change handlers", function()
		local changeCount = 0
		local child = New "Folder" {
        	[Attribute "Foo"] = "Bar",
			[AttributeChange "Foo"] = function()
				changeCount += 1
			end
		}

		child:SetAttribute("Foo", "Baz")
		task.wait()
		expect(changeCount).never.to.equal(0)
	end)

	it("should pass the updated value as an argument", function()
		local updatedValue = ""
		local child = New "Folder" {
			[AttributeChange "Foo"] = function(newValue)
				updatedValue = newValue
			end
		}

		child:SetAttribute("Foo", "Baz")
		task.wait()
		expect(updatedValue).to.equal("Baz")
	end)

	it("should error when given an invalid handler", function()
		expect(function()
			local child = New "Folder" {
				[AttributeChange "Foo"] = 0
			}
		end).to.throw("invalidAttributeChangeHandler")
    end)
end
