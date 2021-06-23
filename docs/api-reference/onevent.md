```Lua
function OnEvent(eventName: string): Symbol
```

Generates symbols used to denote event handlers when working with the [New](../new)
function.

When using this symbol as a key in `New`'s property table, the value is expected
to be a callback function, which will be connected to the given event on the
instance.

The function acts as a normal event handler does; it receives all arguments from
the event. The connection is automatically cleaned up when the instance is
destroyed.

-----

## Parameters

- `eventName: string` - the name of the event on the instance

-----

## Example Usage

```Lua
local example = New "TextButton" {
	[OnEvent "Activated"] = function(...)
		print("Activated event fired with args:", ...)
	end
}
```