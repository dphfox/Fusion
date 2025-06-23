--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local Hydrate = require(Fusion.Instances.Hydrate)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it

	it("should return the instance it was passed", function()
		local expect = getfenv().expect
		
		local scope = {}
		local ins = Instance.new("Folder")
		expect(Hydrate(scope, ins) {}).to.equal(ins)
		doCleanup(scope)
	end)

	it("should apply properties to the instance", function()
		local expect = getfenv().expect
		
		local scope = {}
		local ins = Instance.new("Folder")
		Hydrate(scope, ins) {
			Name = "Jeremy"
		}
		expect(ins.Name).to.equal("Jeremy")
		doCleanup(scope)
	end)
end
