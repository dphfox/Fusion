local Package = game:GetService("ReplicatedStorage").Fusion
local Fusion = require(Package)

return function()
	it("should load with the correct public APIs", function()
		expect(Fusion).to.be.a("table")

		local api = {
			version = "table",

			New = "function",
			Hydrate = "function",
			Ref = "table",
			Out = "function",
			Cleanup = "table",
			Children = "table",
			OnEvent = "function",
			OnChange = "function",

			Value = "function",
			Computed = "function",
			ForPairs = "function",
			ForKeys = "function",
			ForValues = "function",
			Observer = "function",

			Tween = "function",
			Spring = "function",

			cleanup = "function",
			doNothing = "function"
		}

		for apiName, apiType in pairs(api) do
			local realValue = rawget(Fusion, apiName)
			local realType = typeof(realValue)

			if realType ~= apiType then
				error("API member '" .. apiName .. "' expected type '" .. apiType .. "' but got '" .. realType .. "'")
			end
		end

		for realName, realValue in pairs(Fusion) do
			local realType = typeof(realValue)
			local apiType = api[realName] or "nil"

			if realType ~= apiType then
				error("API member '" .. realName .. "' expected type '" .. apiType .. "' but got '" .. realType .. "'")
			end
		end
	end)

	it("should error when accessing non-existent APIs", function()
		expect(function()
			local foo = Fusion.thisIsNotARealAPI
		end).to.throw("strictReadError")
	end)
end