local Package = game:GetService("ReplicatedStorage").Fusion
local Motion = require(Package.Motion)

return function()
	it("should load with the correct public APIs", function()
		expect(Motion).to.be.a("table")

		local api = {
			version = "table",
			
			Tween = "function",
			Spring = "function"
		}

		for apiName, apiType in pairs(api) do
			local realValue = rawget(Motion, apiName)
			local realType = typeof(realValue)

			if realType ~= apiType then
				error("API member '" .. apiName .. "' expected type '" .. apiType .. "' but got '" .. realType .. "'")
			end
		end

		for realName, realValue in pairs(Motion) do
			local realType = typeof(realValue)
			local apiType = api[realName] or "nil"

			if realType ~= apiType then
				error("API member '" .. realName .. "' expected type '" .. apiType .. "' but got '" .. realType .. "'")
			end
		end
	end)

	it("should error when accessing non-existent APIs", function()
		expect(function()
			local foo = Motion.thisIsNotARealAPI
		end).to.throw("strictReadError")
	end)
end