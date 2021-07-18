```Lua
function Computed(callback: () -> any): Computed
```

Constructs and returns a new computed object, using the given callback to
compute this object's values based on other state or computed objects.

-----

## Parameters

- `callback: () -> any` - a function which computes and returns the value to use
for this computed object.

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

-----

## Dependency Management & Updates

Computed objects automatically detect dependencies used inside their callback
each time their callback runs. This means, when you use a function like `:get()`
on a state object, it will register that state object as a dependency:

```Lua
local numCoins = State(50)

local doubleCoins = Computed(function()
	-- Fusion detects we called :get() on `numCoins`, and so adds `numCoins` as
	-- a dependency of this computed object.
	return numCoins:get() * 2
end)
```

When a dependency changes value, the computed object will re-run its callback to
generate and cache the current value internally. This value is later exposed via
the `:get()` method.

Something to note is that dependencies are dynamic; you can change what values
your computed object depends on, and the dependencies will be updated to reduce
unnecessary updates:

=== "Lua"
```Lua
	local stateA = State(5)
	local stateB = State(5)
	local selector = State("A")

	local computed = Computed(function()
		print("> updating computed!")
		local selected = selector:get()
		if selected == "A" then
			return stateA:get()
		elseif selected == "B" then
			return stateB:get()
		end
	end)

	print("increment state A (expect update below)")
	stateA:set(stateA:get() + 1)
	print("increment state B (expect no update)")
	stateA:set(stateA:get() + 1)

	print("switch to select B")
	selector:set("B")

	print("increment state A (expect no update)")
	stateA:set(stateA:get() + 1)
	print("increment state B (expect update below)")
	stateA:set(stateA:get() + 1)
```
=== "Expected output"
```
> updating computed!
increment state A (expect update below)
> updating computed!
increment state B (expect no update)
switch to select B
> updating computed!
increment state A (expect no update)
increment state B (expect update below)
> updating computed!
```

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