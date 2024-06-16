`ForKeys` is a state object that processes keys from another table.

It supports both constants and state objects.

```Lua
local data = {Red = "foo", Blue = "bar"}
local prefix = scope:Value("Key_")

local renamed = scope:ForKeys(data, function(use, scope, key)
	return use(prefix) .. key
end)

print(peek(renamed)) --> {Key_Red = "foo", Key_Blue = "bar"}

prefix:set("colour")
print(peek(renamed)) --> {colourRed = "foo", colourBlue = "bar"}
```

-----

## Usage

To create a new `ForKeys` object, call the constructor with an input table and
a processor function. The first two arguments are `use` and `scope`, just like
[computed objects](../../fundamentals/computeds). The third argument is one of
the keys read from the input table.

```Lua
local data = {red = "foo", blue = "bar"}
local renamed = scope:ForKeys(data, function(use, scope, key)
	return string.upper(key)
end)
```

You can read the table of processed keys using `peek()`:

```Lua hl_lines="6"
local data = {red = "foo", blue = "bar"}
local renamed = scope:ForKeys(data, function(use, scope, key)
	return string.upper(key)
end)

print(peek(renamed)) --> {RED = "foo", BLUE = "bar"}
```

The input table can be a state object. When the input table changes, the output
will update.

```Lua
local foodSet = scope:Value({})

local prefixes = { pie = "tasty", chocolate = "yummy", broccoli = "gross" }
local renamedFoodSet = scope:ForKeys(foodSet, function(use, scope, food)
	return prefixes[food] .. food
end)

foodSet:set({ pie = true })
print(peek(renamedFoodSet)) --> { tasty_pie = true }

foodSet:set({ broccoli = true, chocolate = true })
print(peek(renamedFoodSet)) --> { gross_broccoli = true, yummy_chocolate = true }
```

You can also `use()` state objects in your calculations, just like a computed.

```Lua
local foodSet = scope:Value({ broccoli = true, chocolate = true })

local prefixes = { chocolate = "yummy", broccoli = scope:Value("gross") }
local renamedFoodSet = scope:ForKeys(foodSet, function(use, scope, food)
	return use(prefixes[food]) .. food
end)

print(peek(renamedFoodSet)) --> { gross_broccoli = true, yummy_chocolate = true }

prefixes.broccoli:set("scrumptious")
print(peek(renamedFoodSet)) --> { scrumptious_broccoli = true, yummy_chocolate = true }
```

Anything added to the `scope` is cleaned up for you when the processed key is
removed.

```Lua
local foodSet = scope:Value({ broccoli = true, chocolate = true })

local shoutingFoodSet = scope:ForKeys(names, function(use, scope, food)
	table.insert(scope, function()
		print("I ate the " .. food .. "!")
	end)
	return string.upper(food)
end)

names:set({ chocolate = true }) --> I ate the broccoli!
```

??? tip "How ForKeys optimises your code"
	Rather than creating a new output table from scratch every time the input table
	is changed, `ForKeys` will try and reuse as much as possible to improve
	performance.

	Say you're converting an array to a dictionary:

	```Lua
	local array = scope:Value({"Fusion", "Knit", "Matter"})
	local dict = scope:ForKeys(array, function(use, scope, index)
		return "Value" .. index
	end)

	print(peek(dict)) --> {Value1 = "Fusion", Value2 = "Knit", Value3 = "Matter"}
	```

	Because `ForKeys` only operates on the keys, changing the values in the array
	doesn't affect the keys. Keys are only added or removed as needed:

	```Lua
	local array = scope:Value({"Fusion", "Knit", "Matter"})
	local dict = scope:ForKeys(array, function(use, scope, index)
		return "Value" .. index
	end)

	print(peek(dict)) --> {Value1 = "Fusion", Value2 = "Knit", Value3 = "Matter"}

	array:set({"Roact", "Rodux", "Promise"})
	print(peek(dict)) --> {Value1 = "Roact", Value2 = "Rodux", Value3 = "Promise"}
	```

	`ForKeys` takes advantage of this - when a value changes, it's copied into the
	output table without recalculating the key. Keys are only calculated when a
	value is assigned to a new key.