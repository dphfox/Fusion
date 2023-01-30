```Lua linenums="1"
-- [Fusion imports omitted for clarity]

-- Defining some theme colours. Something to note; I'm intentionally putting the
-- actual colour names as the topmost keys here, and putting `light` and `dark`
-- keys inside the colours. If you did it the other way around, then there's no
-- single source of truth for what colour names are available, and it's hard to
-- keep in sync. If a theme doesn't have a colour, it's better to explicitly not
-- specify it under the colour name.

local THEME_COLOURS = {
	background = {
		light = Color3.fromHex("FFFFFF"),
		dark = Color3.fromHex("2D2D2D")
	},
	text = {
		light = Color3.fromHex("2D2D2D"),
		dark = Color3.fromHex("FFFFFF")
	},
	-- [etc, for all the colours you'd want]
}

-- This will control which colours we're using at the moment. You could expose
-- this to the rest of your code directly, or calculate it using a Computed.
local currentTheme = Value("light")

-- Now we'll create a Computed for every theme colour, which will pick a colour
-- from `THEME_COLS` based on our `currentTheme`.
local currentColours = {}
for colourName, colourOptions in THEME_COLOURS do
	currentColours[colourName] = Computed(function()
		return colourOptions[currentTheme:get()]
	end)
end

-- Now you can expose `colourOptions` to the rest of your code, preferably under
-- a convenient name :)

local text = New "TextLabel" {
	TextColor3 = currentColours.text
}
```