local Package = game:GetService("ReplicatedStorage").Fusion
local Core = require(Package.Core)

return function()
	it("should load with the correct public APIs", function()
		expect(Core).to.be.a("table")

		local api = {
			version = "table",

			Value = "function",
			Computed = "function"
		}

		for apiName, apiType in pairs(api) do
			local realValue = rawget(Core, apiName)
			local realType = typeof(realValue)

			if realType ~= apiType then
				error("API member '" .. apiName .. "' expected type '" .. apiType .. "' but got '" .. realType .. "'")
			end
		end

		for realName, realValue in pairs(Core) do
			local realType = typeof(realValue)
			local apiType = api[realName] or "nil"

			if realType ~= apiType then
				error("API member '" .. realName .. "' expected type '" .. apiType .. "' but got '" .. realType .. "'")
			end
		end
	end)

	it("should error when accessing non-existent APIs", function()
		expect(function()
			local foo = Core.thisIsNotARealAPI
		end).to.throw("strictReadError")
	end)
end