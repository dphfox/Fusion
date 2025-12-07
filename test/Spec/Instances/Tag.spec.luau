--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local New = require(Fusion.Instances.New)
local Tag = require(Fusion.Instances.Tag)
local Value = require(Fusion.State.Value)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it

	it("adds tags (constant)", function()
		local expect = getfenv().expect
		
		local scope = {}
		local child = New(scope, "Folder") {
			[Tag "Foo"] = true
		}
		expect(child:HasTag("Foo")).to.equal(true)
		doCleanup(scope)
	end)

	it("adds tags (state)", function()
		local expect = getfenv().expect
		
		local scope = {}
		local addTag = Value(scope, true)
		local child = New(scope, "Folder") {
			[Tag "Foo"] = addTag
		}
		expect(child:HasTag("Foo")).to.equal(true)
	end)
	
	it("adds/removes tag when state objects are updated", function()
		local expect = getfenv().expect
		
		local scope = {}
		local tagExists = Value(scope, true)
		local child = New(scope, "Folder") {
			[Tag "Foo"] = tagExists
		}
		expect(child:HasTag("Foo")).to.equal(true)
		tagExists:set(false)
		expect(child:HasTag("Foo")).to.equal(false)
		doCleanup(scope)
	end)
end
