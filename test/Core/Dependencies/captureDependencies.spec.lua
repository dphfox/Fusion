local Package = game:GetService("ReplicatedStorage").Fusion
local captureDependencies = require(Package.Core.Dependencies.captureDependencies)
local sharedState = require(Package.Core.Dependencies.sharedState)

return function()
	it("should set a dependency set contextually", function()
		local dependencySet = {}
		captureDependencies(dependencySet, function()
			expect(sharedState.dependencySet).to.equal(dependencySet)
		end)

		expect(sharedState.dependencySet).never.to.equal(dependencySet)
	end)

	it("should correctly contain and resolve errors", function()
		local ok, err
		local dependencySet = {}

		expect(function()
			ok, err = captureDependencies(dependencySet, function()
				error("oops")
			end)
		end).never.to.throw()

		expect(sharedState.dependencySet).never.to.equal(dependencySet)

		expect(ok).to.equal(false)
		expect(err).to.be.a("table")
		expect(err.message).to.equal("oops")
	end)

	it("should pass arguments to the callback", function()
		local value1, value2, value3

		captureDependencies({}, function(...)
			value1, value2, value3 = ...
		end, "foo", nil, "bar")

		expect(value1).to.equal("foo")
		expect(value2).to.equal(nil)
		expect(value3).to.equal("bar")
	end)

	it("should return values from the callback", function()
		local _, value, value2 = captureDependencies({}, function(...)
			return "foo", "bar"
		end)

		expect(value).to.equal("foo")
		expect(value2).to.equal("bar")
	end)
end