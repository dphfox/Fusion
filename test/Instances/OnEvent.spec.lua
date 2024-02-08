local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local Children = require(Package.Instances.Children)
local OnEvent = require(Package.Instances.OnEvent)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	it("should connect event handlers", function()
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

		task.wait()

		expect(fires).never.to.equal(0)
		doCleanup(scope)
	end)

	it("should throw for non-existent events", function()
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
		expect(function()
			local scope = {}
			New(scope, "Folder") {
				Name = "Foo",

				[OnEvent "Name"] = function() end
			}
			doCleanup(scope)
		end).to.throw("cannotConnectEvent")
	end)

	it("shouldn't fire events during initialisation", function()
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

		task.wait()

		expect(totalFires).to.equal(0)
		doCleanup(scope)
	end)
end
