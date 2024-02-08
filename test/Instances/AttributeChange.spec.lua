local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local Attribute = require(Package.Instances.Attribute)
local AttributeChange = require(Package.Instances.AttributeChange)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	it("should connect attribute change handlers", function()
		local scope = {}
		local changeCount = 0
		local child = New(scope, "Folder") {
			[Attribute "Foo"] = "Bar",
			[AttributeChange "Foo"] = function()
				changeCount += 1
			end
		}

		child:SetAttribute("Foo", "Baz")
		task.wait()
		expect(changeCount).never.to.equal(0)
		doCleanup(scope)
	end)

	it("should pass the updated value as an argument", function()
		local scope = {}
		local updatedValue = ""
		local child = New(scope, "Folder") {
			[AttributeChange "Foo"] = function(newValue)
				updatedValue = newValue
			end
		}

		child:SetAttribute("Foo", "Baz")
		task.wait()
		expect(updatedValue).to.equal("Baz")
		doCleanup(scope)
	end)

	it("should error when given an invalid handler", function()
		expect(function()
			local scope = {}
			local child = New(scope, "Folder") {
				[AttributeChange "Foo"] = 0
			}
			doCleanup(scope)
		end).to.throw("invalidAttributeChangeHandler")
	end)
end
