```Lua
function OnChange(propertyName: string): Symbol
```

Generates symbols used to denote property change handlers when working with the
[New](../new) function.

When using this symbol as a key in `New`'s property table, the value is expected
to be a callback function. The callback will be connected to the property's
`GetPropertyChangedSignal` event on the instance.

Unlike normal property change handlers, the new value is passed in as an
argument to the callback for convenience.

!!! warning "Using OnChange with bound state"
	When passing a [state object](../state) or [computed object](../computed) as
	a property, changes in the state will only affect the property on the next
	render step (a concept known as 'deferred updating').

	Because `OnChange` connects to `GetPropertyChangedSignal`, it's possible
	to introduce subtle off-by-one-frame errors if you depend on `OnChange` to
	keep other things in sync with the property. Prefer to connect to the state's
	`onChange` event instead.

-----

## Parameters

- `propertyName: string` - the property to watch for changes on the instance

-----

## Example Usage

```Lua
local example = New "TextBox" {
	[OnChange "Text"] = function(newText)
		print("You typed:", newText)
	end
}
```