--[[
	Stores 'sensible default' properties to be applied to instances created by
	the New function.
]]

local ENABLE_SENSIBLE_DEFAULTS = true

if ENABLE_SENSIBLE_DEFAULTS then
	return {
		ScreenGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = "Sibling"
		},

		BillboardGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = "Sibling"
		},

		SurfaceGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = "Sibling",

			SizingMode = "PixelsPerStud",
			PixelsPerStud = 50
		},

		Frame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0
		},

		ScrollingFrame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,

			ScrollBarImageColor3 = Color3.new(0, 0, 0)
		},

		TextLabel = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,

			Font = "SourceSans",
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14
		},

		TextButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,

			AutoButtonColor = false,

			Font = "SourceSans",
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14
		},

		TextBox = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,

			ClearTextOnFocus = false,

			Font = "SourceSans",
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14
		},

		ImageLabel = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0
		},

		ImageButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,

			AutoButtonColor = false
		},

		ViewportFrame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0
		},

		VideoFrame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0
		}
	}
else
	return {}
end