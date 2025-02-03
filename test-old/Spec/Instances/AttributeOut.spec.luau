--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local New = require(Fusion.Instances.New)
local Attribute = require(Fusion.Instances.Attribute)
local AttributeOut = require(Fusion.Instances.AttributeOut)
local Value = require(Fusion.State.Value)
local peek = require(Fusion.State.peek)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it
	local itSKIP = getfenv().itSKIP

	-- TODO: the event is spawned by Roblox's task scheduler, so it doesn't work
	-- with our testing architecture anymore.

	itSKIP("should update when attributes are changed externally", function()
		local expect = getfenv().expect
		
		local scope = {}
		local attributeValue = Value(scope, nil)
		local child = New(scope, "Folder") {
			[AttributeOut "Foo"] = attributeValue
		}

		expect(peek(attributeValue)).to.equal(nil)
		child:SetAttribute("Foo", "Bar")
		expect(peek(attributeValue)).to.equal("Bar")
		doCleanup(scope)
	end)

	-- TODO: the event is spawned by Roblox's task scheduler, so it doesn't work
	-- with our testing architecture anymore.

	itSKIP("should update when state objects linked update", function()
		local expect = getfenv().expect
		
		local scope = {}
		local attributeValue = Value(scope, "Foo")
		local attributeOutValue = Value(scope, nil)
		New(scope, "Folder") {
			[Attribute "Foo"] = attributeValue,
			[AttributeOut "Foo"] = attributeOutValue
		}
		expect(peek(attributeOutValue)).to.equal("Foo")
		attributeValue:set("Bar")
		expect(peek(attributeOutValue)).to.equal("Bar")
		doCleanup(scope)
	end)

	-- TODO: the event is spawned by Roblox's task scheduler, so it doesn't work
	-- with our testing architecture anymore.

	itSKIP("should work with two-way connections", function()
		local expect = getfenv().expect
		
		local scope = {}
		local attributeValue = Value(scope, "Bar")
		local child = New(scope, "Folder") {
			[Attribute "Foo"] = attributeValue,
			[AttributeOut "Foo"] = attributeValue
		}

		expect(peek(attributeValue)).to.equal("Bar")
		attributeValue:set("Baz")
		expect(child:GetAttribute("Foo")).to.equal("Baz")
		child:SetAttribute("Foo", "Biff")
		expect(peek(attributeValue)).to.equal("Biff")
		doCleanup(scope)
	end)
end