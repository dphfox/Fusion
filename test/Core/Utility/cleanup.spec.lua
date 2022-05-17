local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local cleanup = require(Package.Core.Utility.cleanup)

return function()
	it("should destroy instances", function()
		local instance = New "Folder" {}
		-- one of the only reliable ways to test for proper destruction
		local conn = instance.AncestryChanged:Connect(function() end)

		cleanup(instance)

		expect(conn.Connected).to.equal(false)
	end)

	it("should disconnect connections", function()
		local instance = New "Folder" {}
		local conn = instance.AncestryChanged:Connect(function() end)

		cleanup(conn)

		expect(conn.Connected).to.equal(false)
	end)

	it("should invoke callbacks", function()
		local didRun = false

		cleanup(function()
			didRun = true
		end)

		expect(didRun).to.equal(true)
	end)

	it("should invoke :destroy() methods", function()
		local didRun = false

		cleanup({
			destroy = function()
				didRun = true
			end
		})

		expect(didRun).to.equal(true)
	end)

	it("should invoke :Destroy() methods", function()
		local didRun = false

		cleanup({
			Destroy = function()
				didRun = true
			end
		})

		expect(didRun).to.equal(true)
	end)

	it("should clean up contents of arrays", function()
		local numRuns = 0

		local function doRun()
			numRuns += 1
		end

		cleanup({doRun, doRun, doRun})

		expect(numRuns).to.equal(3)
	end)

	it("should clean up contents of nested arrays", function()
		local numRuns = 0

		local function doRun()
			numRuns += 1
		end

		cleanup({{doRun, {doRun, {doRun}}}})

		expect(numRuns).to.equal(3)
	end)

	it("should clean up contents of arrays in order", function()
		local runs = {}

		local tasks = {}

		tasks[3] = function()
			table.insert(runs, 3)
		end

		tasks[1] = function()
			table.insert(runs, 1)
		end

		tasks[2] = function()
			table.insert(runs, 2)
		end

		cleanup(tasks)

		expect(runs[1]).to.equal(1)
		expect(runs[2]).to.equal(2)
		expect(runs[3]).to.equal(3)
	end)
end