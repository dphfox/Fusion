--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local New = require(Fusion.Instances.New)
local Attribute = require(Fusion.Instances.Attribute)
local AttributeChange = require(Fusion.Instances.AttributeChange)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it
	local itSKIP = getfenv().itSKIP

	-- TODO: the event is spawned by Roblox's task scheduler, so it doesn't work
	-- with our testing architecture anymore.

	itSKIP("should connect attribute change handlers", function()
		local expect = getfenv().expect
		
		local scope = {}
		local changeCount = 0
		local child = New(scope, "Folder") {
			[Attribute "Foo"] = "Bar",
			[AttributeChange "Foo"] = function()
				changeCount += 1
			end
		}

		child:SetAttribute("Foo", "Baz")
		expect(changeCount).never.to.equal(0)
		doCleanup(scope)
	end)

	-- TODO: the event is spawned by Roblox's task scheduler, so it doesn't work
	-- with our testing architecture anymore.

	itSKIP("should pass the updated value as an argument", function()
		local expect = getfenv().expect
		
		local scope = {}
		local updatedValue = ""
		local updated = false
		local child = New(scope, "Folder") {
			[AttributeChange "Foo"] = function(newValue)
				updatedValue = newValue
				updated = true
			end
		}

		child:SetAttribute("Foo", "Baz")
		expect(updatedValue).to.equal("Baz")
		doCleanup(scope)
	end)

	it("should error when given an invalid handler", function()
		local expect = getfenv().expect
		
		expect(function()
			local scope = {}
			New(scope, "Folder") {
				[AttributeChange "Foo"] = 0
			}
			doCleanup(scope)
		end).to.throw("invalidAttributeChangeHandler")
	end)
end
