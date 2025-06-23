--!strict

local tiniest = require("../../lib/tiniest_for_roblox")

local doCleanup = require("../../../src/Memory/doCleanup")

return function(tiniest: tiniest.Configured): ()
	local describe = tiniest.describe
	local test = tiniest.test
	local expect = tiniest.expect

	test("callback", function()
		local run = false
		doCleanup(function()
			run = true
		end)
		expect(run).is(true)
	end)

	describe("methods", function()
		for _, method in {"destroy", "Destroy"} do
			test("destroy", function()
				local run = false
				doCleanup({
					destroy = function(self)
						expect(self).exists()
						run = true
					end
				})
				expect(run).is(true)
			end)
		end
	end)

	test("scope", function()
		local runs = {}
		local scope = {}
		scope[3] = function()
			table.insert(runs, 3)
		end
		scope[1] = function()
			table.insert(runs, 1)
		end
		scope[2] = function()
			table.insert(runs, 2)
		end
		doCleanup(scope)
		expect(runs[1]).is(3)
		expect(runs[2]).is(2)
		expect(runs[3]).is(1)
	end)

	test("recursion", function()
		local function foo()
			doCleanup(foo)
		end
		expect(foo).fails_with("destroyedTwice")
	end)

	describe("roblox", function()
		test("instance", function()
			local instance = Instance.new("Folder")
			doCleanup(instance)
			expect(function()
				instance.Parent = instance
			end).fails_with("locked")
		end)

		test("connection", function()
			local instance = Instance.new("Folder")
			local connection = instance.AncestryChanged:Connect(function() end)
			doCleanup(instance)
			expect(connection.Connected).is(false)
		end)
	end)
	
end