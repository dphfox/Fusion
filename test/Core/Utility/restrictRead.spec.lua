local Package = game:GetService("ReplicatedStorage").Fusion
local restrictRead = require(Package.Core.Utility.restrictRead)

return function()
	it("should error for missing members", function()
		local strictTable = restrictRead("", {})

		expect(function()
			local x = strictTable.thisDoesNotExist
		end).to.throw("strictReadError")
	end)

	it("should not error for present members", function()
		local strictTable = restrictRead("", {
			foo = 2,
			bar = "blue"
		})

		expect(function()
			local x = strictTable.foo
			local y = strictTable.bar
		end).never.to.throw()
	end)

	it("should preserve metatables", function()
		local metatable = {}
		local strictTable = setmetatable({}, metatable)
		restrictRead("", strictTable)

		expect(getmetatable(strictTable)).to.equal(metatable)
	end)
end