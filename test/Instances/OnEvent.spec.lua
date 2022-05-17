local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local Children = require(Package.Instances.Children)
local OnEvent = require(Package.Instances.OnEvent)

local waitForGC = require(script.Parent.Parent.Utility.waitForGC)

return function()
	it("should connect event handlers", function()
		local fires = 0
		local ins = New "Folder" {
			Name = "Foo",

			[OnEvent "AncestryChanged"] = function()
				fires += 1
			end
		}

		ins.Parent = game
		ins:Destroy()

		task.wait()

		expect(fires).never.to.equal(0)
	end)

	it("should throw for non-existent events", function()
		expect(function()
			New "Folder" {
				Name = "Foo",

				[OnEvent "Frobulate"] = function() end
			}
		end).to.throw("cannotConnectEvent")
	end)

	it("should throw for non-event event handlers", function()
		expect(function()
			New "Folder" {
				Name = "Foo",

				[OnEvent "Name"] = function() end
			}
		end).to.throw("cannotConnectEvent")
	end)

	it("shouldn't fire events during initialisation", function()
		local fires = 0
		local ins = New "Folder" {
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

			[Children] = New "Folder" {
				Name = "Bar"
			}
		}

		local totalFires = fires
		ins:Destroy()

		task.wait()

		expect(totalFires).to.equal(0)
	end)

	it("should not inhibit garbage collection", function()
		local ref = setmetatable({}, {__mode = "v"})
		do
			ref[1] = New "Folder" {
				[OnEvent "Changed"] = function() end
			}
		end

		waitForGC()

		expect(ref[1]).to.equal(nil)
	end)
end