local Package = game:GetService("ReplicatedStorage").Fusion

local New = require(Package.Instances.New)
local Attribute = require(Package.Instances.Attribute)
local Value = require(Package.State.Value)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	it("creates attributes (constant)", function()
		local scope = {}
		local child = New(scope, "Folder") {
			[Attribute "Foo"] = "Bar"
		}
		expect(child:GetAttribute("Foo")).to.equal("Bar")
		doCleanup(scope)
	end)

	it("creates attributes (state)", function()
		local scope = {}
		local attributeValue = Value(scope, "Bar")
		local child = New(scope, "Folder") {
			[Attribute "Foo"] = attributeValue
		}
		expect(child:GetAttribute("Foo")).to.equal("Bar")
	end)
	
	it("updates attributes when state objects are updated", function()
		local scope = {}
		local attributeValue = Value(scope, "Bar")
		local child = New(scope, "Folder") {
			[Attribute "Foo"] = attributeValue
		}
		expect(child:GetAttribute("Foo")).to.equal("Bar")
		attributeValue:set("Baz")
		task.wait()
		expect(child:GetAttribute("Foo")).to.equal("Baz")
		doCleanup(scope)
	end)

	it("defers attribute changes", function()
		local scope = {}
		local value = Value(scope, "Bar")
		local child = New(scope, "Folder") {
			[Attribute "Foo"] = value
		}
		value:set("Baz")
		expect(child:GetAttribute("Foo")).to.equal("Bar")
		task.wait()
		expect(child:GetAttribute("Foo")).to.equal("Baz")
	end)
end
