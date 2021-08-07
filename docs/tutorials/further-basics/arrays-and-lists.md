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

