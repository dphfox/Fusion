```Lua
function ComputedPairs(
	originalTable: StateOrValue<{[any]: any}>,
	processor: (key: any, value: any) -> any,
	destructor: ((any) -> any)?
): Computed
```

Constructs and returns a new computed object, which generates a table by
processing values from another table. The table may be passed in directly or
stored in a state object.

Specifically, this object constructs a new table, and for each key-value pair
in `originalTable`, passes the pair into `processor` to generate a new value,
then saves the new value to the new table using the existing key.

If `originalTable` is a state object, then the new table will be updated as
`originalTable` is updated; new pairs will be generated, existing pairs will be
cached, and deleted pairs will be removed.

When a pair is removed, the generated value (originally from `processor`) may
optionally be passed into a `destructor` function - this is useful if you're
generating values that require cleanup, such as instances. If no `destructor` is
provided, then a default Maid-like destructor will be used:

- Instances will be destroyed
- Event connections will be disconnected
- Functions will be invoked
- Tables with :destroy() or :Destroy() methods will have those methods called
- Arrays will have their values destructed

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
