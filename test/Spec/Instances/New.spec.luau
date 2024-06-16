--!strict
--!nolint LocalUnused
local task = nil -- Disable usage of Roblox's task scheduler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = ReplicatedStorage.Fusion

local New = require(Fusion.Instances.New)
local defaultProps = require(Fusion.Instances.defaultProps)
local doCleanup = require(Fusion.Memory.doCleanup)

return function()
	local it = getfenv().it

	it("should create a new instance", function()
		local expect = getfenv().expect
		
		local scope = {}
		local ins = New (scope, "Frame") {}
		expect(typeof(ins) == "Instance").to.be.ok()
		expect(ins:IsA("Frame")).to.be.ok()
	end)

	it("should throw for non-existent class types", function()
		local expect = getfenv().expect
		
		expect(function()
			local scope = {}
			New (scope, "This is not a valid class type") {}
			doCleanup(scope)
		end).to.throw("cannotCreateClass")
	end)

	it("should apply 'sensible default' properties", function()
		local expect = getfenv().expect
		
		for className, defaults in pairs(defaultProps) do
			local scope = {}
			local ins = New (scope, className) {}
			for propName, propValue in pairs(defaults) do
				expect((ins :: any)[propName]).to.equal(propValue)
			end
			doCleanup(scope)
		end
	end)

	it("doesn't incorrectly cache scope between invocations", function()
		local expect = getfenv().expect
		
		local scope1 = {}
		local scope2 = {}
		New (scope1, "Frame") {}
		New (scope2, "Frame") {}
		expect(#scope1).to.equal(1)
		expect(#scope2).to.equal(1)
		
		doCleanup(scope1)
		doCleanup(scope2)
	end)
end
