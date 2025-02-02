--!strict

local tiniest = require("../../lib/tiniest_for_roblox")

local doCleanup = require("../../../src/Memory/doCleanup")

return function(tiniest: tiniest.Configured): ()
	local describe = tiniest.describe
	local test = tiniest.test
	local expect = tiniest.expect

	describe("data types", function()
		test("instance", function()
			local instance = Instance.new("Folder")
			local watch = instance.AncestryChanged:Connect(function() end)
	
			doCleanup(instance)
	
			expect(watch.Connected).is(false)
		end)
	end)
	
end