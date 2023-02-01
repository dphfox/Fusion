`ForPairs` combines the functions of `ForValues` and `ForKeys` into one object.
It can process pairs of keys and values at the same time.

The input table can be a state object, and the output values can use state
objects.

```Lua
local itemColours = { shoes = "red", socks = "blue" }
local owner = Value("Elttob")

local manipulated = ForPairs(itemColours, function(thing, colour)
	local newKey = colour
	local newValue = owner:get() .. "'s " .. thing
	return newKey, newValue
end)

print(manipulated:get()) --> {red = "Elttob's shoes", blue = "Elttob's socks"}

owner:set("Quenty")
print(manipulated:get()) --> {red = "Quenty's shoes", blue = "Quenty's socks"}
```

-----

## Usage

To use `ForPairs` in your code, you first need to import it from the Fusion
module, so that you can refer to it by name:

```Lua linenums="1" hl_lines="2"
local Fusion = require(ReplicatedStorage.Fusion)
local ForPairs = Fusion.ForPairs
```

### Basic Usage

To create a new `ForPairs` object, call the constructor with an input table and
a processor function:

```Lua
local itemColours = { shoes = "red", socks = "blue" }
local swapped = ForPairs(data, function(key, value)
	return value, key
end)
```

This will generate a new table, where each key-value pair is replaced using the
processor function. You can get the table using the `:get()` method:

```Lua hl_lines="6"
local itemColours = { shoes = "red", socks = "blue" }
local swapped = ForPairs(data, function(key, value)
	return value, key
end)

print(swapped:get()) --> {red = "shoes", blue = "socks"}
```

### State Objects

As with `ForKeys` and `ForValues`, the input table can be provided as a state
object, and the processor function can use other state objects in its
calculations. [See the ForValues page for examples.](./forvalues.md#state-objects)

### Cleanup Behaviour

Similar to `ForValues` and `ForKeys`, you may pass in a 'destructor' function to
add cleanup behaviour, and send your own metadata to it:

```Lua
local watchedInstances = Value({
	[workspace.Part1] = "One",
	[workspace.Part2] = "Two",
	[workspace.Part3] = "Three"
})

local connectionSet = ForPairs(eventSet, 
	-- processor
	function(instance, displayName)
		local metadata = { displayName = displayName, numChanges = 0 }
		local connection = instance.Changed:Connect(function()
			print("Instance", displayName, "was changed!")
			metadata.numChanges += 1
		end)
		return instance, connection, metadata
	end,
	-- destructor
	function(instance, connection, metadata)
		print("Removing", metadata.displayName, "after", metadata.numChanges, "changes")
		connection:Disconnect() -- don't forget we're overriding the default cleanup
	end
)

-- remove Part3 from the input table
-- this will run the destructor with Part3, its Changed event, and its metadata
watchedInstances:set({
	[workspace.Part1] = "One",
	[workspace.Part2] = "Two"
})
```

-----

## Optimisations

!!! help "Optional"
	You don't have to memorise these optimisations to use `ForPairs`, but it
	can be helpful if you have a performance problem.

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
matter, [ForValues can move values between keys.](./forvalues.md#optimisations)

Alternatively, if you're working with a set of objects stored in keys, and don't
need the values in the table,
[ForKeys will ignore the values for optimal performance.](./forkeys.md#optimisations)