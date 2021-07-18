```Lua
function State(initialValue: any?): State
```

Constructs and returns a new state object, with an optional initial value.

-----

## Parameters

- `initialValue: any?` - the value which should initially be stored in the state
object.

-----

## Object Methods

### `get()`

```Lua
function State:get(): any
```
Returns the currently stored value of this state object.

If dependencies are currently being detected (e.g. inside a computed callback),
then this state object will be used as a dependency.

### `set()`

```Lua
function State:set(newValue: any)
```
Sets the new value of this state object.

If the new and old values differ, this will fire `onChange` and update all
dependent state objects immediately.

-----

## Object Events

### `onChange`

Fired when the value of this state object is changed.

-----

## Example Usage

```Lua
local numCoins = State(50)

print(numCoins:get()) --> 50

numCoins:set(25)
print(numCoins:get()) --> 25

numCoins.onChange:Connect(function()
	print("Coins changed to:", numCoins:get())
end)
```