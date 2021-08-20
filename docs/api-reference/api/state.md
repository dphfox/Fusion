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
function State:set(newValue: any, force: boolean?)
```
Sets the new value of this state object.

If the new and old values differ, this will update any other objects using this
state object. However, if they're the same, no update will be performed.

!!! tip "Force updating"
	If you want to override this behaviour, you can set `force` to `true`. This
	will ensure updates are always performed, even if the new and old values
	are the same (as measured by the == operator). This is most useful when
	working with mutable tables.

	However, be very careful with this, and only force updates when you need to
	for performance reasons. Try a solution involving immutable tables first.
	Abuse of force updating can lead to suboptimal code that updates redundantly.

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