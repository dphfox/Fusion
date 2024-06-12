This example demonstrates how to create dynamic theme colours using Fusion's
state objects.

-----

## Overview

```Lua linenums="1"
local Fusion = --initialise Fusion here however you please!
local scoped = Fusion.scoped

local Theme = {}

Theme.colours = {
	background = {
		light = Color3.fromHex("FFFFFF"),
		dark = Color3.fromHex("222222")
	},
	text = {
		light = Color3.fromHex("222222"),
		dark = Color3.fromHex("FFFFFF")
	}
}

-- Don't forget to pass this to `doCleanup` if you disable the script.
local scope = scoped(Fusion)

Theme.current = scope:Value("light")
Theme.dynamic = {}
for colour, variants in Theme.colours do
	Theme.dynamic[colour] = scope:Computed(function(use)
		return variants[use(Theme.current)]
	end)
end

Theme.current:set("light")
print(peek(Theme.dynamic.background)) --> 255, 255, 255

Theme.current:set("dark")
print(peek(Theme.dynamic.background)) --> 34, 34, 34
```

-----

## Explanation

To begin, this example defines a set of colours with light and dark variants.

```Lua
Theme.colours = {
	background = {
		light = Color3.fromHex("FFFFFF"),
		dark = Color3.fromHex("222222")
	},
	text = {
		light = Color3.fromHex("222222"),
		dark = Color3.fromHex("FFFFFF")
	}
}
```

A `Value` object stores which variant is in use right now.

```Lua
Theme.current = scope:Value("light")
```

Finally, each colour is turned into a `Computed`, which dynamically pulls the
desired variant from the list.

```Lua
Theme.dynamic = {}
for colour, variants in Theme.colours do
	Theme.dynamic[colour] = scope:Computed(function(use)
		return variants[use(Theme.current)]
	end)
end
```

This allows other code to easily access theme colours from `Theme.dynamic`.

```Lua
Theme.current:set("light")
print(peek(Theme.dynamic.background)) --> 255, 255, 255

Theme.current:set("dark")
print(peek(Theme.dynamic.background)) --> 34, 34, 34
```