local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local OnChange = require(Package.Instances.OnChange)
local doCleanup = require(Package.Memory.doCleanup)

return function()
	it("should connect property change handlers", function()
		local scope = {}
		local fires = 0
		local ins = New(scope, "Folder") {
			Name = "Foo",

			[OnChange "Name"] = function(newName)
				fires += 1
			end
		}

		ins.Name = "Bar"
		task.wait()
		expect(fires).never.to.equal(0)
		doCleanup(scope)
	end)

	it("should pass the new value to the handler", function()
		local scope = {}
		local arg = nil
		local ins = New(scope, "Folder") {
			Name = "Foo",

			[OnChange "Name"] = function(newName)
				arg = newName
			end
		}

		ins.Name = "Bar"
		task.wait()
		expect(arg).to.equal("Bar")
		doCleanup(scope)
	end)

	it("should throw when connecting to non-existent property changes", function()
		local scope = {}
		expect(function()
			New(scope, "Folder") {
				Name = "Foo",

				[OnChange "Frobulate"] = function() end
			}
			doCleanup(scope)
		end).to.throw("cannotConnectChange")
	end)

	it("shouldn't fire property changes during initialisation", function()
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
		task.wait()
		expect(totalFires).to.equal(0)
		doCleanup(scope)
	end)
end
