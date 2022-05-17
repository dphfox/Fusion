local Package = game:GetService("ReplicatedStorage").Fusion
local useDependency = require(Package.Core.Dependencies.useDependency)
local sharedState = require(Package.Core.Dependencies.sharedState)

return function()
	it("should add to a dependency set contextually", function()
		local dependencySet = {}
		sharedState.dependencySet = dependencySet

		local dependency = {get = function() end}
		useDependency(dependency)

		sharedState.dependencySet = nil

		expect(dependencySet[dependency]).to.be.ok()
	end)

	it("should do nothing when no dependency set exists", function()
		expect(function()
			useDependency({get = function() end})
		end).never.to.throw()

		expect(sharedState.dependencySet).never.to.be.ok()
	end)

	-- TODO: test in conjunction with initDependency
end