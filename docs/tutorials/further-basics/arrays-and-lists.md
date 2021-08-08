Efficiently working with tables can be difficult normally. Let's learn about the
tools Fusion provides to make working with arrays and tables easier.

??? abstract "Required code"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	local State = Fusion.State
	local Computed = Fusion.Computed

	local numbers = State({1, 2, 3, 4, 5})
	```

-----

## Computed Arrays

Suppose we have a state object storing an array of numbers, and we'd like to
create a computed object which doubles each number. You could achieve this with
a for-pairs loop:

```Lua linenums="7" hl_lines="3-9"
local numbers = State({1, 2, 3, 4, 5})

local doubledNumbers = Computed(function()
	local doubled = {}
	for index, number in pairs(numbers) do
		doubled[index] = number * 2
	end
	return doubled
end)

print(doubledNumbers:get()) --> {2, 4, 6, 8, 10}
```

While this works, it's pretty verbose. To make this code simpler, Fusion has a
special computed object designed for processing arrays of values, known as
`ComputedPairs`.

To use it, we need to import `ComputedPairs` from Fusion:

```Lua linenums="1" hl_lines="7"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Fusion = require(ReplicatedStorage.Fusion)

local State = Fusion.State
local Computed = Fusion.Computed
local ComputedPairs = Fusion.ComputedPairs
```

`ComputedPairs` acts similarly to the for-pairs loop we wrote above - it goes
through each entry of the array, processes the value, and saves it into the
new array:

```Lua linenums="8" hl_lines="3-5"
local numbers = State({1, 2, 3, 4, 5})

local doubledNumbers = ComputedPairs(function(index, number)
	return number *  2
end)

print(doubledNumbers:get()) --> {2, 4, 6, 8, 10}
```

This can be used to process any kind of table, not just arrays. Notice how the
keys stay the same, and the value is whatever you return:

```Lua
local data = State({Blue = "good", Green = "bad"})

local processedData = ComputedPairs(function(colour, word)
	return colour .. " is " .. word
end)

print(processedData:get()) --> {Blue = "Blue is good", Green = "Green is bad"}
```

-----

## Cleaning Up Values

Sometimes, you might use `ComputedPairs` to generate lists of instances, or
other similar data types. When we're done with these, we need to destroy them.

Conveniently, `ComputedPairs` already cleans up some types when they're removed
from the output array:

- returned instances will be destroyed
- returned event connections will be disconnected
- returned functions will be run
- returned objects will have their `:Destroy()` or `:destroy()` methods called
- returned arrays will have their contents cleaned up

This should cover most use cases by default. However, if you need to override
this cleanup behaviour, you can pass in an optional `destructor` function as
the second argument. It will be called any time a generated value is removed or
overwritten, so you can clean it up:

=== "Lua"
	```Lua linenums="8" hl_lines="7-9"
	local names = State({"John", "Dave", "Sebastian"})

	local greetings = ComputedPairs(
		function(index, name)
			return "Hello, " .. name
		end,
		function(greeting)
			print("Removed: " .. greeting)
		end
	)

	names:set("John", "Trey", "Charlie")
	```
=== "Expected output"
	```
	Removed: Hello, Dave
	Removed: Hello, Sebastian
	```

-----

## Optimisation

To improve performance, `ComputedPairs` doesn't recalculate a key if its value
stays the same:

=== "Lua"
	```Lua
	local data = State({
		One = 1,
		Two = 2,
		Three = 3
	})

	print("Creating processedData...")

	local processedData = ComputedPairs(function(key, value)
		print("  ...recalculating key: " .. key)
		return value * 2
	end)

	print("Changing the values of some keys...")
	data:set({
		One = 1,
		Two = 100,
		Three = 3,
		Four = 4
	})
	```
=== "Expected output"
	```
	Creating processedData...
	  ...recalculating key: One
	  ...recalculating key: Two
	  ...recalculating key: Three
	Changing the values of some keys...
	  ...recalculating key: Two
	  ...recalculating key: Four
	```

Because the keys `Two` and `Four` have different values after the change,
they're recalculated. However, `One` and `Three` have the same values, so
they'll be reused instead:

![Diagram showing how keys are cached](OptimisedKeyValues.png)

Be careful, though - this means arrays may not be optimised by default. To be
specific, if the values in your array change position, they'll be recalculated,
because each key may now correspond to a different value:

=== "Lua"
	```Lua
	local data = State({"Red", "Green", "Blue", "Yellow"})

	print("Creating processedData...")

	local processedData = ComputedPairs(function(key, value)
		print("  ...recalculating key: " .. key .. " value: " .. value)
		return value * 2
	end)

	print("Moving the values around...")
	data:set({"Blue", "Yellow", "Red", "Green"})
	```
=== "Expected output"
	```
	Creating processedData...
	  ...recalculating key: 1 value: Red
	  ...recalculating key: 2 value: Green
	  ...recalculating key: 3 value: Blue
	  ...recalculating key: 4 value: Yellow
	Moving the values around...
	  ...recalculating key: 1 value: Blue
	  ...recalculating key: 2 value: Yellow
	  ...recalculating key: 3 value: Red
	  ...recalculating key: 4 value: Green
	```

These keys are considered 'unstable', because

If the order of the values doesn't matter, you can use the values as keys
instead, which solves the problem. Now, the only time a value is recalculated
is when a key is added:

=== "Lua"
	```Lua
	local data = State({Red = true, Green = true, Blue = true, Yellow = true})

	print("Creating processedData...")

	local processedData = ComputedPairs(function(key)
		print("  ...recalculating key: " .. key)
		return key * 2
	end)

	print("Adding a new value...")
	data:set({Red = true, Green = true, Yellow = true, Pink = true, Blue = true})
	```
=== "Expected output"
	```
	Creating processedData...
	  ...recalculating key: Red
	  ...recalculating key: Green
	  ...recalculating key: Blue
	  ...recalculating key: Yellow
	Adding a new value...
	  ...recalculating key: Pink
	```

This is a concept known as 'stable keys'.