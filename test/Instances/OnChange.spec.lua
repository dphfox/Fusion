local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local OnChange = require(Package.Instances.OnChange)

local waitForGC = require(script.Parent.Parent.Utility.waitForGC)

return function()
	it("should connect property change handlers", function()
		local fires = 0
		local ins = New "Folder" {
			Name = "Foo",

			[OnChange "Name"] = function(newName)
				fires += 1
			end
		}

		ins.Name = "Bar"
		task.wait()
		expect(fires).never.to.equal(0)
	end)

	it("should pass the new value to the handler", function()
		local arg = nil
		local ins = New "Folder" {
			Name = "Foo",

			[OnChange "Name"] = function(newName)
				arg = newName
			end
		}

		ins.Name = "Bar"
		task.wait()
		expect(arg).to.equal("Bar")
	end)

	it("should throw when connecting to non-existent property changes", function()
		expect(function()
			New "Folder" {
				Name = "Foo",

				[OnChange "Frobulate"] = function() end
			}
		end).to.throw("cannotConnectChange")
	end)

	it("shouldn't fire property changes during initialisation", function()
		local fires = 0
		local ins = New "Folder" {
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
		task.wait()
		expect(totalFires).to.equal(0)
	end)

	it("should not inhibit garbage collection", function()
		local ref = setmetatable({}, {__mode = "v"})
		do
			ref[1] = New "Folder" {
				[OnChange "Name"] = function() end
			}
		end

		waitForGC()

		expect(ref[1]).to.equal(nil)
	end)
end