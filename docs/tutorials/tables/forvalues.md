`ForValues` is a state object that processes values from another table.

It supports both constants and state objects.

```Lua
local numbers = {1, 2, 3, 4, 5}
local multiplier = Value(2)

local multiplied = ForValues(numbers, function(use, scope, num)
	return num * use(multiplier)
end)

print(peek(multiplied)) --> {2, 4, 6, 8, 10}

multiplier:set(10)
print(peek(multiplied)) --> {10, 20, 30, 40, 50}
```

-----

## Usage

To create a new `ForValues` object, call the constructor with an input table and
a processor function. The first two arguments are `use` and `scope`, just like
[computed objects](../../fundamentals/computeds). The third argument is one of the
values read from the input table.

```Lua
local numbers = {1, 2, 3, 4, 5}
local doubled = scope:ForValues(numbers, function(use, scope, num)
	return num * 2
end)
```

You can read the table of processed values using `peek()`:

```Lua hl_lines="6"
local numbers = {1, 2, 3, 4, 5}
local doubled = scope:ForValues(numbers, function(use, scope, num)
	return num * 2
end)

print(peek(doubled)) --> {2, 4, 6, 8, 10}
```

The input table can be a state object. When the input table changes, the output
will update.

```Lua
local numbers = scope:Value({})
local doubled = scope:ForValues(numbers, function(use, scope, num)
	return num * 2
end)

numbers:set({1, 2, 3, 4, 5})
print(peek(doubled)) --> {2, 4, 6, 8, 10}

numbers:set({5, 15, 25})
print(peek(doubled)) --> {10, 30, 50}
```

You can also `use()` state objects in your calculations, just like a computed.

```Lua
local numbers = {1, 2, 3, 4, 5}
local factor = scope:Value(2)
local multiplied = scope:ForValues(numbers, function(use, scope, num)
	return num * use(factor)
end)

print(peek(multiplied)) --> {2, 4, 6, 8, 10}

factor:set(10)
print(peek(multiplied)) --> {10, 20, 30, 40, 50}
```

Anything added to the `scope` is cleaned up for you when the processed value is
removed.

```Lua
local names = scope:Value({"Jodi", "Amber", "Umair"})
local shoutingNames = scope:ForValues(names, function(use, scope, name)
	table.insert(scope, function()
		print("Goodbye, " .. name .. "!")
	end)
	return string.upper(name)
end)

names:set({"Amber", "Umair"}) --> Goodbye, Jodi!
```

??? tip "How ForValues optimises your code"
	Rather than creating a new output table from scratch every time the input table
	is changed, `ForValues` will try and reuse as much as possible to improve
	performance.

	Say you're measuring the lengths of an array of words:

	```Lua
	local words = scope:Value({"Orange", "Red", "Magenta"})
	local lengths = scope:ForValues(words, function(use, scope, word)
		return #word
	end)

	print(peek(lengths)) --> {6, 3, 7}
	```

	The word lengths don't depend on the position of the word in the array. This
	means that rearranging the words in the input array will just rearrange the
	lengths in the output array:

	![A diagram visualising how the values move around.](Optimisation-Reordering-Dark.svg#only-dark)
	![A diagram visualising how the values move around.](Optimisation-Reordering-Light.svg#only-light)

	`ForValues` takes advantage of this - when input values move around, the output
	values will move around too, instead of being recalculated.

	Note that values are only reused once. For example, if you added another
	occurence of 'Orange', your calculation would have to run again for the second
	'Orange':

	![A diagram visualising how values aren't reused when duplicates appear.](Optimisation-Duplicates-Dark.svg#only-dark)
	![A diagram visualising how values aren't reused when duplicates appear.](Optimisation-Duplicates-Light.svg#only-light)