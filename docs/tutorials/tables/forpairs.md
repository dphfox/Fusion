`ForPairs` is like `ForValues` and `ForKeys` in one object. It can process pairs
of keys and values at the same time.

It supports both constants and state objects.

```Lua
local itemColours = { shoes = "red", socks = "blue" }
local owner = scope:Value("Janet")

local manipulated = scope:ForPairs(itemColours, function(use, scope, thing, colour)
	local newKey = colour
	local newValue = use(owner) .. "'s " .. thing
	return newKey, newValue
end)

print(peek(manipulated)) --> {red = "Janet's shoes", blue = "Janet's socks"}

owner:set("April")
print(peek(manipulated)) --> {red = "April's shoes", blue = "April's socks"}
```

-----

## Usage

To create a new `ForPairs` object, call the constructor with an input table and
a processor function. The first two arguments are `use` and `scope`, just like
[computed objects](../../fundamentals/computeds). The third and fourth arguments
are one of the key-value pairs read from the input table.

```Lua
local itemColours = { shoes = "red", socks = "blue" }
local swapped = scope:ForPairs(data, function(use, scope, item, colour)
	return colour, item
end)
```

You can read the processed table using `peek()`:

```Lua hl_lines="6"
local itemColours = { shoes = "red", socks = "blue" }
local swapped = scope:ForPairs(data, function(use, scope, item, colour)
	return colour, item
end)

print(peek(swapped)) --> { red = "shoes", blue = "socks" }
```

The input table can be a state object. When the input table changes, the output
will update.

```Lua 
local itemColours = scope:Value({ shoes = "red", socks = "blue" })
local swapped = scope:ForPairs(data, function(use, scope, item, colour)
	return colour, item
end)

print(peek(swapped)) --> { red = "shoes", blue = "socks" }

itemColours:set({ sandals = "red", socks = "green" })
print(peek(swapped)) --> { red = "sandals", green = "socks" }
```

You can also `use()` state objects in your calculations, just like a computed.

```Lua
local itemColours = { shoes = "red", socks = "blue" }

local shouldSwap = scope:Value(false)
local swapped = scope:ForPairs(data, function(use, scope, item, colour)
	if use(shouldSwap) then
		return colour, item
	else
		return item, colour
	end
end)

print(peek(swapped)) --> { shoes = "red", socks = "blue" }

shouldSwap:set(true)
print(peek(swapped)) --> { red = "shoes", blue = "socks" }
```

Anything added to the `scope` is cleaned up for you when either the processed
key or the processed value is removed.

```Lua 
local itemColours = scope:Value({ shoes = "red", socks = "blue" })
local swapped = scope:ForPairs(data, function(use, scope, item, colour)
	table.insert(scope, function()
		print("No longer wearing " .. colour .. " " .. item)
	end)
	return colour, item
end)

itemColours:set({ shoes = "red", socks = "green" }) --> No longer wearing blue socks
```

??? tip "How ForPairs optimises your code"
	Rather than creating a new output table from scratch every time the input table
	is changed, `ForPairs` will try and reuse as much as possible to improve
	performance.

	Since `ForPairs` has to depend on both keys and values, changing any value in
	the input table will cause a recalculation for that key-value pair.

	![A diagram showing values of keys changing in a table.](Optimisation-KeyValueChange-Dark.svg#only-dark)
	![A diagram showing values of keys changing in a table.](Optimisation-KeyValueChange-Light.svg#only-light)

	Inversely, `ForPairs` won't recalculate any key-value pairs that stay the same.
	Instead, these will be preserved in the output table.

	![A diagram showing values of keys staying the same in a table.](Optimisation-KeyValuePreserve-Dark.svg#only-dark)
	![A diagram showing values of keys staying the same in a table.](Optimisation-KeyValuePreserve-Light.svg#only-light)

	If you don't need the keys or the values, Fusion can offer better optimisations.
	For example, if you're working with an array of values where position doesn't
	matter, [ForValues can move values between keys.](./forvalues.md)

	Alternatively, if you're working with a set of objects stored in keys, and don't
	need the values in the table,
	[ForKeys will ignore the values for optimal performance.](./forkeys.md)