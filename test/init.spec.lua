local Package = game:GetService("ReplicatedStorage").Fusion
local Fusion = require(Package)

return function()
	it("should load with the correct public APIs", function()
		expect(Fusion).to.be.a("table")

		local api = {
			version = "table",

			cleanup = "function",
			doCleanup = "function",
			doNothing = "function",
			scoped = "function",
			deriveScope = "function",

			peek = "function",
			Value = "function",
			Computed = "function",
			ForPairs = "function",
			ForKeys = "function",
			ForValues = "function",
			Observer = "function",
			
			Tween = "function",
			Spring = "function",

			New = "function",
			Hydrate = "function",
			
			Ref = "table",
			Out = "function",
			Children = "table",
			OnEvent = "function",
			OnChange = "function",
			Attribute = "function",
			AttributeChange = "function",
			AttributeOut = "function"
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

	it("should not error when accessing non-existent APIs", function()
		expect(function()
			local foo = Fusion["thisIsNotARealAPI" :: any]
		end).never.to.throw()
	end)
end