--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local New = require(Fusion.Instances.New)
local Out = require(Fusion.Instances.Out)
local Value = require(Fusion.State.Value)
local peek = require(Fusion.State.peek)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it
	local itSKIP = getfenv().itSKIP

	-- TODO: the event is spawned by Roblox's task scheduler, so it doesn't work
	-- with our testing architecture anymore.

	itSKIP("should reflect external property changes", function()
		local expect = getfenv().expect
		
		local scope = {}
		local outValue = Value(scope, nil)

		local child = New(scope, "Folder") {
			[Out "Name"] = outValue
		}
		expect(peek(outValue)).to.equal("Folder")

		child.Name = "Mary"
		expect(peek(outValue)).to.equal("Mary")
		doCleanup(scope)
	end)

	-- TODO: the event is spawned by Roblox's task scheduler, so it doesn't work
	-- with our testing architecture anymore.

	itSKIP("should reflect property changes from bound state", function()
		local expect = getfenv().expect
		
		local scope = {}
		local outValue = Value(scope, nil)
		local inValue = Value(scope, "Gabriel")

		New(scope, "Folder") {
			Name = inValue,
			[Out "Name"] = outValue
		}
		expect(peek(outValue)).to.equal("Gabriel")

		inValue:set("Joseph")
		expect(peek(outValue)).to.equal("Joseph")
		doCleanup(scope)
	end)

	-- TODO: the event is spawned by Roblox's task scheduler, so it doesn't work
	-- with our testing architecture anymore.

	itSKIP("should support two-way data binding", function()
		local expect = getfenv().expect
		
		local scope = {}
		local twoWayValue = Value(scope, "Gabriel")

		local child = New(scope, "Folder") {
			Name = twoWayValue,
			[Out "Name"] = twoWayValue
		}
		expect(peek(twoWayValue)).to.equal("Gabriel")

		twoWayValue:set("Joseph")
		expect(child.Name).to.equal("Joseph")

		child.Name = "Elias"
		expect(peek(twoWayValue)).to.equal("Elias")
		doCleanup(scope)
	end)
end
