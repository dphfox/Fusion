--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local New = require(Fusion.Instances.New)
local Attribute = require(Fusion.Instances.Attribute)
local Value = require(Fusion.State.Value)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it

	it("creates attributes (constant)", function()
		local expect = getfenv().expect
		
		local scope = {}
		local child = New(scope, "Folder") {
			[Attribute "Foo"] = "Bar"
		}
		expect(child:GetAttribute("Foo")).to.equal("Bar")
		doCleanup(scope)
	end)

	it("creates attributes (state)", function()
		local expect = getfenv().expect
		
		local scope = {}
		local attributeValue = Value(scope, "Bar")
		local child = New(scope, "Folder") {
			[Attribute "Foo"] = attributeValue
		}
		expect(child:GetAttribute("Foo")).to.equal("Bar")
	end)
	
	it("updates attributes when state objects are updated", function()
		local expect = getfenv().expect
		
		local scope = {}
		local attributeValue = Value(scope, "Bar")
		local child = New(scope, "Folder") {
			[Attribute "Foo"] = attributeValue
		}
		expect(child:GetAttribute("Foo")).to.equal("Bar")
		attributeValue:set("Baz")
		expect(child:GetAttribute("Foo")).to.equal("Baz")
		doCleanup(scope)
	end)
end
