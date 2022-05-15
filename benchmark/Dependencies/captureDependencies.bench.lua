local Package = game:GetService("ReplicatedStorage").Fusion
local captureDependencies = require(Package.Core.Dependencies.captureDependencies)

local function callback()

end

return {

	{
		name = "Capture dependencies from callback",
		calls = 50000,

		preRun = function()
			return {}
		end,

		run = function(state)
			captureDependencies(state, callback)
		end
	}

}