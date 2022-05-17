local Package = game:GetService("ReplicatedStorage").Fusion
local Oklab = require(Package.Motion.Colour.Oklab)

return {

	{
		name = "Convert to Oklab",
		calls = 50000,

		preRun = function()
			return {
				colour = Color3.new(0.25, 0.5, 0.75)
			}
		end,

		run = function(state)
			Oklab.to(state.colour)
		end
	},

	{
		name = "Convert from Oklab",
		calls = 50000,

		preRun = function()
			return {
				colour = Vector3.new(0.25, 0.5, 0.75)
			}
		end,

		run = function(state)
			Oklab.from(state.colour)
		end
	}

}