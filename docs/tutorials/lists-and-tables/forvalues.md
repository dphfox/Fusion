`ForValues` is a state object that creates a new table by processing values from
another table.

The input table can be a state object, and the output values can use state
objects.

```Lua
local numbers = {1, 2, 3, 4, 5}
local multiplier = Value(2)

local multiplied = ForValues(numbers, function(num)
	return num * multiplier:get()
end)

print(multiplied:get()) --> {2, 4, 6, 8, 10}

multiplier:set(10)
print(multiplied:get()) --> {10, 20, 30, 40, 50}
```

-----

## Usage

To use `ForValues` in your code, you first need to import it from the Fusion
module, so that you can refer to it by name:

```Lua linenums="1" hl_lines="2"
local Fusion = require(ReplicatedStorage.Fusion)
local ForValues = Fusion.ForValues
```

### Basic Usage

To create a new `ForValues` object, call the constructor with an input table and
a processor function:

```Lua
local numbers = {1, 2, 3, 4, 5}
local doubled = ForValues(numbers, function(num)
	return num * 2
end)
```

This will generate a new table of values, where each value is passed through the
processor function. You can get the table using the `:get()` method:

```Lua hl_lines="6"
local numbers = {1, 2, 3, 4, 5}
local doubled = ForValues(numbers, function(num)
	return num * 2
end)

print(doubled:get()) --> {2, 4, 6, 8, 10}
```

### State Objects

The input table can be provided as a state object instead, and the output table
will update as the input table is changed:

```Lua
local numbers = Value({})
local doubled = ForValues(numbers, function(num)
	return num * 2
end)

numbers:set({1, 2, 3, 4, 5})
print(doubled:get()) --> {2, 4, 6, 8, 10}

numbers:set({5, 15, 25})
print(doubled:get()) --> {10, 30, 50}
```

Additionally, you can use state objects in your calculations, just like a
computed:

```Lua
local numbers = {1, 2, 3, 4, 5}
local factor = Value(2)
local multiplied = ForValues(numbers, function(num)
	return num * factor:get()
end)

print(multiplied:get()) --> {2, 4, 6, 8, 10}

factor:set(10)
print(multiplied:get()) --> {10, 20, 30, 40, 50}
```

### Cleanup Behaviour

Similar to computeds, if you want to run your own code when values are removed,
you can pass in a second 'destructor' function:

```Lua hl_lines="9-13"
local names = Value({"Jodi", "Amber", "Umair"})
local textLabels = ForValues(names,
	-- processor
	function(name)
		return New "TextLabel" {
			Text = name
		}
	end,
	-- destructor
	function(textLabel)
		print("Destructor got text label:", textLabel.Text)
		textLabel:Destroy() -- don't forget we're overriding the default cleanup
	end
)

-- remove Jodi from the names list
-- this will run the destructor with Jodi's TextLabel
names:set({"Amber", "Umair"}) --> Destructor got text label: Jodi
```

When using a custom destructor, you can send one extra return value to your
destructor without including it in the output table:

```Lua hl_lines="11 14"
local names = Value({"Jodi", "Amber", "Umair"})
local textLabels = ForValues(names,
	-- processor
	function(name)
		local textLabel = New "TextLabel" {
			Text = name
		}
		local uppercased = name:upper()
		-- `textLabel` will be included in the output table
		-- `uppercased` is not included, but still passed to the destructor
		return textLabel, uppercased
	end,
	-- destructor
	function(textLabel, uppercased)
		print("Destructor got uppercased:", uppercased)
		textLabel:Destroy()
	end
)

names:set({"Amber", "Umair"}) --> Destructor got uppercased: JODI
```

-----

## Optimisations

!!! help "Optional"
	You don't have to memorise these optimisations to use `ForValues`, but it
	can be helpful if you have a performance problem.

Rather than creating a new output table from scratch every time the input table
is changed, `ForValues` will try and reuse as much as possible to improve
performance.

For example, let's say we're measuring the lengths of an array of words:

```Lua
local words = Value({"Orange", "Red", "Magenta"})
local lengths = ForValues(words, function(word)
	return #word
end)

print(lengths:get()) --> {6, 3, 7}
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