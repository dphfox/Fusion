--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local New = require(Fusion.Instances.New)
local Ref = require(Fusion.Instances.Ref)
local Value = require(Fusion.State.Value)
local peek = require(Fusion.State.peek)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it

	it("should set State objects passed as [Ref]", function()
		local expect = getfenv().expect
		
		local scope = {}
		local refValue = Value(scope, nil)

		local child = New(scope, "Folder") {
			[Ref] = refValue
		}

		expect(peek(refValue)).to.equal(child)
		doCleanup(scope)
	end)
end
