local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local Cleanup = require(Package.Instances.Cleanup)

local waitForGC = require(script.Parent.Parent.Utility.waitForGC)

return function()
	it("should destroy instances", function()
		local instance = New "Folder" {}
		-- one of the only reliable ways to test for proper destruction
		local conn = instance.AncestryChanged:Connect(function() end)

		local child = New "Folder" {
			[Cleanup] = instance
		}
		child:Destroy()
		task.wait()

		expect(conn.Connected).to.equal(false)
	end)

	it("should disconnect connections", function()
		local instance = New "Folder" {}
		local conn = instance.AncestryChanged:Connect(function() end)

		local child = New "Folder" {
			[Cleanup] = conn
		}
		child:Destroy()
		task.wait()

		expect(conn.Connected).to.equal(false)
	end)

	it("should invoke callbacks", function()
		local didRun = false

		local child = New "Folder" {
			[Cleanup] = function()
				didRun = true
			end
		}
		child:Destroy()
		task.wait()

		expect(didRun).to.equal(true)
	end)

	it("should invoke :destroy() methods", function()
		local didRun = false

		local child = New "Folder" {
			[Cleanup] = {
				destroy = function()
					didRun = true
				end
			}
		}
		child:Destroy()
		task.wait()

		expect(didRun).to.equal(true)
	end)

	it("should invoke :Destroy() methods", function()
		local didRun = false

		local child = New "Folder" {
			[Cleanup] = {
				Destroy = function()
					didRun = true
				end
			}
		}
		child:Destroy()
		task.wait()

		expect(didRun).to.equal(true)
	end)

	it("should clean up contents of arrays", function()
		local numRuns = 0

		local function doRun()
			numRuns += 1
		end

		local child = New "Folder" {
			[Cleanup] = {doRun, doRun, doRun}
		}
		child:Destroy()
		task.wait()

		expect(numRuns).to.equal(3)
	end)

	it("should clean up contents of nested arrays", function()
		local numRuns = 0

		local function doRun()
			numRuns += 1
		end

		local child = New "Folder" {
			[Cleanup] = {{doRun, {doRun, {doRun}}}}
		}
		child:Destroy()
		task.wait()

		expect(numRuns).to.equal(3)
	end)

	it("should not inhibit garbage collection", function()
		local ref = setmetatable({}, {__mode = "v"})
		do
			ref[1] = New "Folder" {
				[Cleanup] = function() end
			}
		end

		waitForGC()

		expect(ref[1]).to.equal(nil)
	end)
end