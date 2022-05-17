local Package = game:GetService("ReplicatedStorage").Fusion
local State = require(Package.State)

return function()
	it("should load with the correct public APIs", function()
		expect(State).to.be.a("table")

		local api = {
			version = "table",

			ForPairs = "function",
			ForKeys = "function",
			ForValues = "function",
			Observer = "function"
		}

		for apiName, apiType in pairs(api) do
			local realValue = rawget(State, apiName)
			local realType = typeof(realValue)

			if realType ~= apiType then
				error("API member '" .. apiName .. "' expected type '" .. apiType .. "' but got '" .. realType .. "'")
			end
		end

		for realName, realValue in pairs(State) do
			local realType = typeof(realValue)
			local apiType = api[realName] or "nil"

			if realType ~= apiType then
				error("API member '" .. realName .. "' expected type '" .. apiType .. "' but got '" .. realType .. "'")
			end
		end
	end)

	it("should error when accessing non-existent APIs", function()
		expect(function()
			local foo = State.thisIsNotARealAPI
		end).to.throw("strictReadError")
	end)
end