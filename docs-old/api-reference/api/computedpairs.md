```Lua
function ComputedPairs(
	inputTable: StateOrValue<{[any]: any}>,
	processor: (key: any, value: any) -> any,
	destructor: ((any) -> any)?
): Computed
```

Constructs and returns a new computed object, which generates a table by
processing values from another table.

The input table may be passed in directly, or inside a state object or computed
object.

The output table will have all the keys of the input table, but all the values
will be passed through the `processor` function.

When values are removed from the output table, they may optionally be passed
through a `destructor` function. This allows you to properly clean up some types
such as instances - [more details can be found in the tutorial.](../../../tutorials/further-basics/arrays-and-lists)

-----

## Parameters

- `inputTable: StateOrValue<{[any]: any}>` - a table, or state object containing
a table, which will be read by this ComputedPairs
- `processor: (key: any, value: any) -> any` - values from the input table will
be passed through this function and placed in the table returned by this object
- `destructor: ((any) -> any)?` - when a value is removed from the output
table, it will be passed to this function for cleanup. If not provided, defaults
to a Maid-like cleanup function.

-----

## Object Methods

### `get()`

```Lua
function ComputedPairs:get(): any
```
Returns the cached value of this computed object, which will be the output table
of key/value pairs.

If dependencies are currently being detected (e.g. inside a computed callback),
then this computed object will be used as a dependency.

-----

## Example Usage

```Lua
local playerList = State({
	"AxisAngles",
	"boatbomber",
	"Elttob",
	"grilme99",
	"Phalanxia",
	"Reselim",
	"thisfall"
})

local textLabels = ComputedPairs(playerList, function(key, value)
	return New "TextLabel" {
		Text = value
	}
end)
```