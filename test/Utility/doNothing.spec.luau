local Package = game:GetService("ReplicatedStorage").Fusion
local New = require(Package.Instances.New)
local doNothing = require(Package.Utility.doNothing)

return function()
	it("should not destroy instances", function()
		local instance = New "Folder" {}
		-- one of the only reliable ways to test for proper destruction
		local conn = instance.AncestryChanged:Connect(function() end)

		doNothing(instance)

		expect(conn.Connected).to.equal(true)
	end)

	it("should not disconnect connections", function()
		local instance = New "Folder" {}
		local conn = instance.AncestryChanged:Connect(function() end)

		doNothing(conn)

		expect(conn.Connected).to.equal(true)
	end)

	it("should not invoke callbacks", function()
		local didRun = false

		doNothing(function()
			didRun = true
		end)

		expect(didRun).to.equal(false)
	end)

	it("should not invoke :destroy() methods", function()
		local didRun = false

		doNothing({
			destroy = function()
				didRun = true
			end
		})

		expect(didRun).to.equal(false)
	end)

	it("should not invoke :Destroy() methods", function()
		local didRun = false

		doNothing({
			Destroy = function()
				didRun = true
			end
		})

		expect(didRun).to.equal(false)
	end)

	it("should not clean up contents of arrays", function()
		local numRuns = 0

		local function doRun()
			numRuns += 1
		end

		doNothing({doRun, doRun, doRun})

		expect(numRuns).to.equal(0)
	end)

	it("should not clean up contents of nested arrays", function()
		local numRuns = 0

		local function doRun()
			numRuns += 1
		end

		doNothing({{doRun, {doRun, {doRun}}}})

		expect(numRuns).to.equal(0)
	end)
end