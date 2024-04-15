--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local New = require(Fusion.Instances.New)
local Children = require(Fusion.Instances.Children)
local OnEvent = require(Fusion.Instances.OnEvent)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it
	local itSKIP = getfenv().itSKIP

	-- TODO: the event is spawned by Roblox's task scheduler, so it doesn't work
	-- with our testing architecture anymore.

	itSKIP("should connect event handlers", function()
		local expect = getfenv().expect
		
		local scope = {}
		local fires = 0
		local ins = New(scope, "Folder") {
			Name = "Foo",

			[OnEvent "AncestryChanged"] = function()
				fires += 1
			end
		}

		ins.Parent = game
		ins:Destroy()

		expect(fires).never.to.equal(0)
		doCleanup(scope)
	end)

	it("should throw for non-existent events", function()
		local expect = getfenv().expect
		
		expect(function()
			local scope = {}
			New(scope, "Folder") {
				Name = "Foo",

				[OnEvent "Frobulate"] = function() end
			}
			doCleanup(scope)
		end).to.throw("cannotConnectEvent")
	end)

	it("should throw for non-event event handlers", function()
		local expect = getfenv().expect
		
		expect(function()
			local scope = {}
			New(scope, "Folder") {
				Name = "Foo",

				[OnEvent "Name"] = function() end
			}
			doCleanup(scope)
		end).to.throw("cannotConnectEvent")
	end)

	-- TODO: the event is spawned by Roblox's task scheduler, so it doesn't work
	-- with our testing architecture anymore.

	itSKIP("shouldn't fire events during initialisation", function()
		local expect = getfenv().expect
		
		local scope = {}
		local fires = 0
		local ins = New(scope, "Folder") {
			Parent = game,
			Name = "Foo",

			[OnEvent "ChildAdded"] = function()
				fires += 1
			end,

			[OnEvent "Changed"] = function()
				fires += 1
			end,

			[OnEvent "AncestryChanged"] = function()
				fires += 1
			end,

			[Children] = New(scope, "Folder") {
				Name = "Bar"
			}
		}

		local totalFires = fires
		ins:Destroy()

		expect(totalFires).to.equal(0)
		doCleanup(scope)
	end)
end
