--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local New = require(Fusion.Instances.New)
local OnChange = require(Fusion.Instances.OnChange)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it
	local itSKIP = getfenv().itSKIP

	-- TODO: the event is spawned by Roblox's task scheduler, so it doesn't work
	-- with our testing architecture anymore.

	itSKIP("should connect property change handlers", function()
		local expect = getfenv().expect
		
		local scope = {}
		local fires = 0
		local ins = New(scope, "Folder") {
			Name = "Foo",

			[OnChange "Name"] = function(newName)
				fires += 1
			end
		}

		ins.Name = "Bar"
		expect(fires).never.to.equal(0)
		doCleanup(scope)
	end)

	-- TODO: the event is spawned by Roblox's task scheduler, so it doesn't work
	-- with our testing architecture anymore.

	itSKIP("should pass the new value to the handler", function()
		local expect = getfenv().expect
		
		local scope = {}
		local arg = nil
		local ins = New(scope, "Folder") {
			Name = "Foo",

			[OnChange "Name"] = function(newName)
				arg = newName
			end
		}

		ins.Name = "Bar"
		expect(arg).to.equal("Bar")
		doCleanup(scope)
	end)

	it("should throw when connecting to non-existent property changes", function()
		local expect = getfenv().expect
		
		local scope = {}
		expect(function()
			New(scope, "Folder") {
				Name = "Foo",

				[OnChange "Frobulate"] = function() end
			}
			doCleanup(scope)
		end).to.throw("cannotConnectChange")
	end)

	-- TODO: the event is spawned by Roblox's task scheduler, so it doesn't work
	-- with our testing architecture anymore.

	itSKIP("shouldn't fire property changes during initialisation", function()
		local expect = getfenv().expect
		
		local scope = {}
		local fires = 0
		local ins = New(scope, "Folder") {
			Parent = game,
			Name = "Foo",

			[OnChange "Name"] = function()
				fires += 1
			end,

			[OnChange "Parent"] = function()
				fires += 1
			end
		}

		local totalFires = fires
		ins:Destroy()
		expect(totalFires).to.equal(0)
		doCleanup(scope)
	end)
end
