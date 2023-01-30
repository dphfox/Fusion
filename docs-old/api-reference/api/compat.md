```Lua
function Compat(watchedState: State<any>): Compat
```

Constructs and returns a new compatibility object, which will listen for events
on the given `watchedState` object.

Compat is intended as an API for integrating Fusion with other, non-Fusion code.
Some example uses include synchronising theme colours to non-Fusion UIs, or
saving state objects to data stores as they change.

!!! warning
	You should only use `Compat` when dealing with non-Fusion code.

	If you're building an interface with Fusion, there are already reactive
	tools for almost every single use case, which can be better optimised by
	Fusion and lead to cleaner and more idiomatic code. Using `Compat` in these
	situations is highly discouraged.

	Changing state objects in `:onChange()` is a particular anti-pattern which
	abusing Compat may encourage. If you need to update the value of a state
	object when another state object is changed, consider using [computed state](../computed.md)
	instead.

	[For further details, see this issue on GitHub.](https://github.com/Elttob/Fusion/issues/8#issuecomment-888109650)

-----

## Parameters

- `watchedState: State<any>` - a [state object](../state.md), [computed object](../computed.md)
or other state object to track.

-----

## Object Methods

### `onChange()`

```Lua
function Compat:onChange(callback: () -> ()): () -> ()
```
Connects the given callback as a change handler, and returns a function which
will disconnect the callback.

When the value of this Compat's `watchedState` changes, the callback will be
fired.

!!! danger "Connection memory leaks"
	Make sure to disconnect any change handlers made using this function once
	you're done using them.

	As long as a change handler is connected, this Compat object (and the
	`watchedState`) will be held in memory so changes can be detected. This
	means that, if you don't call the disconnect function, you may end up
	accidentally holding the state object in memory after you're done using them.

-----

## Example Usage

```Lua
local numCoins = State(50)

local compat = Compat(numCoins)

local disconnect = compat:onChange(function()
	print("coins is now:", numCoins:get())
end)

numCoins:set(25) -- prints 'coins is now: 25'

-- always clean up your connections!
disconnect()
```