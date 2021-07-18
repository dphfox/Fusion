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
such as instances - more details can be found below.

-----

## Parameters

- `callback: () -> any` - a function which computes and returns the value to use
for this computed object.

-----

## Object Methods

### `get()`

```Lua
function Computed:get(): any
```
Returns the cached value of this computed object, as returned from the callback
function.

If dependencies are currently being detected (e.g. inside a computed callback),
then this computed object will be used as a dependency.

-----

## Object Events

### `onChange`

Fired when the cached value of this computed object is changed.

-----

## Example Usage

```Lua
local numCoins = State(50)

local doubleCoins = Computed(function()
	return numCoins:get() * 2
end)

print(doubleCoins:get()) --> 100

numCoins:set(2)
print(doubleCoins:get()) --> 4
```
