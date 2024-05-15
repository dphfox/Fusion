--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local New = require(Fusion.Instances.New)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it

	it("should destroy instances", function()
		local expect = getfenv().expect
		
		local instance = New({}, "Folder") {}
		-- one of the only reliable ways to test for proper destruction
		local conn = instance.AncestryChanged:Connect(function() end)

		doCleanup(instance)

		expect(conn.Connected).to.equal(false)
	end)

	it("should disconnect connections", function()
		local expect = getfenv().expect
		
		local instance = New({}, "Folder") {}
		local conn = instance.AncestryChanged:Connect(function() end)

		doCleanup(conn)

		expect(conn.Connected).to.equal(false)
	end)

	it("should invoke callbacks", function()
		local expect = getfenv().expect
		
		local didRun = false

		doCleanup(function()
			didRun = true
		end)

		expect(didRun).to.equal(true)
	end)

	it("should invoke :destroy() methods", function()
		local expect = getfenv().expect
		
		local didRun = false

		doCleanup({
			destroy = function()
				didRun = true
			end
		})

		expect(didRun).to.equal(true)
	end)

	it("should invoke :Destroy() methods", function()
		local expect = getfenv().expect
		
		local didRun = false

		doCleanup({
			Destroy = function()
				didRun = true
			end
		})

		expect(didRun).to.equal(true)
	end)

	it("should clean up contents of arrays", function()
		local expect = getfenv().expect
		
		local numRuns = 0

		local function doRun()
			numRuns += 1
		end

		local arr = {doRun, doRun, doRun}

		doCleanup(arr)

		expect(numRuns).to.equal(3)
		expect(arr[3]).to.equal(nil)
		expect(arr[2]).to.equal(nil)
		expect(arr[1]).to.equal(nil)
	end)

	it("should clean up contents of nested arrays", function()
		local expect = getfenv().expect
		
		local numRuns = 0

		local function doRun()
			numRuns += 1
		end

		doCleanup({{doRun :: any, {doRun :: any, {doRun}}}})

		expect(numRuns).to.equal(3)
	end)

	it("should clean up contents of arrays in reverse order", function()
		local expect = getfenv().expect
		
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

		doCleanup(tasks)

		expect(runs[1]).to.equal(3)
		expect(runs[2]).to.equal(2)
		expect(runs[3]).to.equal(1)
	end)

	it("should throw for recursive cleanups", function()
		local expect = getfenv().expect
		
		local function cleanupFunc()
			doCleanup(cleanupFunc)
		end

		expect(function()
			doCleanup(cleanupFunc)
		end).to.throw("destroyedTwice")
	end)
end