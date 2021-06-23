If your code isn't working properly, or if Fusion is malfunctioning, you may see
some errors being printed to the output. Each message comes with a unique ID at
the end.

On this page, you can learn more about any error messages you're receiving.

-----

## `computedCallbackError`

```
Computed callback error: attempt to index a nil value
```

When you create a new [computed object](/api-reference/api/computed.md), you
can pass in a callback. The callback determines the computed object's value:

```Lua
local example = Computed(function()
	-- this is the computed's callback
	return 2 + 2
end)
```

If an error is thrown inside of the callback, this message will show with
details of the error.

Furthermore, if your code attempts to `:get()` the value of a computed object
that errored last time it attempted a computation, the same error will be thrown.

If you're seeing this error, consider the following:

- Is there a bug or unhandled edge case in your callback?
- Is your computed object using correct, valid data?
- Are you trying to access data which doesn't exist yet? (for example, trying
to index something expected to be a table, but which currently is `nil`)
- Are you calling a function which can error sometimes, but aren't catching the
error using `pcall`?

-----

## `cannotCreateClass`

```
Can't create a new instance of class 'Foo'.
Did you spell the class name correctly?
```

When using the [New](../new) function to construct instances,
you're required to pass in a string specifying the class type of the instance:

```Lua
-- this will create a new Folder instance called MyThing
local folder = New "Folder" {
	Name = "MyThing"
}
```

However, if an invalid class type is passed in, then this error will be thrown.

If you're seeing this error, consider the following:

- Did you spell the class name correctly?
- Are you trying to instantiate a class type which is not creatable?
- Does your script have the necessary privileges to create that class type?

-----

## `cannotAssignProperty`

```
The class type 'Foo' has no assignable property 'Bar'.
Did you spell the property name correctly?
```

When using the [New](../new) function to construct instances,
you're able to pass in properties to be assigned to the instance:

```Lua
-- this will create a new Folder instance called MyThing
local folder = New "Folder" {
	Name = "MyThing"
}
```

However, if you attempt to assign a non-existent or locked property, then this
error will be thrown.

If you're seeing this error, consider the following:

- Did you spell the property name correctly?
- Does your script have the necessary privileges to assign that property?

-----

## `strictReadError`

```
'Foo' is not a valid member of 'Bar'.
Did you spell the member name correctly?
```

In Fusion, some tables may have strict reading rules. This is typically used on
public APIs as a defense against typos.

If you're seeing this error, consider the following:

- Did you spell the member name correctly?
- Are you trying to access a member that doesn't exist?
	- You might encounter this problem after updating Fusion, if you're moving
	to a version with breaking changes. Make sure to review your code for bugs!

-----

## `eventNotFound`

```
The Frame class doesn't have an event called 'Foo'.
Did you spell the event name correctly?
```

When using the [New](../new) function to construct instances,
you can register event handlers by using the [OnEvent](../onevent)
function and passing an event name:

```Lua
-- this will print a message when a user clicks this button
local button = New "TextButton" {
	[OnEvent "Activated"] = function()
		print("I was clicked!")
	end)
}
```

However, if no event with that name was found, then you'll see this error.

If you're seeing this error, consider the following:

- Did you spell the event name correctly?
- Are you using a property name instead of an event name?
	- If you want to handle property change events, consider using the `Changed`
	event, or registering a property change handler using [OnChange](../onchange).

-----

## `propertyNotFound`

```
The Frame class doesn't have a property called 'Foo'.
Did you spell the property name correctly?
```

When using the [New](../new) function to construct instances,
you can register property change handlers by using the [OnChange](../onchange)
function and passing a property name:

```Lua
-- this will print a message when a user types in this text box
local button = New "TextBox" {
	[OnChange "Text"] = function(newText)
		print("You typed:", newText)
	end)
}
```

However, if no property with that name was found, then you'll see this error.

If you're seeing this error, consider the following:

- Did you spell the property name correctly?

-----

## `unrecognisedPropertyKey`

```
'number' keys aren't accepted in the property table of `New`.
Make sure you're only passing strings or symbols as keys.
```

When you create an instance in Fusion using [New](../new),
you can pass in a 'property table' containing properties, children, event and
property change handlers, etc.

This table is only expected to contain keys of two types:

- string keys, e.g. `#!Lua Name = "Example"`
- symbol keys, e.g. `#!Lua [OnEvent "Foo"] = ...`

If keys of a different type are present, it's usually not intentional. Fusion
will ignore any key/value pairs with unrecognised key types, but will produce
this warning to make sure you're aware of the issue.

If you're getting this warning, consider the following:

- Does your property table have an array part? For example:
```Lua
New "ScreenGui" {
	Name = "Example",

	-- this Frame isn't going to be added as a child!
	-- it's being added to the array part of the table, and so it'll have a
	-- number key, which will produce this warning
	New "Frame" {
		...
	}
}
```
- If you're building the property table at runtime, are you accidentally indexing
non-string or non-symbol parts of the table? For example:
```Lua
local propertyTable = {}

for key, value in pairs(someData) do
	-- are you sure that `key` is valid here?
	-- if `someData` was an array, then `key` would be a number!
	propertyTable[key] = value
end

New "Part" (propertyTable)
```

-----

## `unknownMessage`

```
Unknown message - the code logging this message didn't provide a valid message
ID.
```

When Fusion code attempts to log a message, warning or error, it needs to
provide an ID. This ID is used to show the correct message, and serves as a
simple, memorable identifier if you need to look up the message later.
However, if that code provides an invalid ID, then the message will be replaced
with this one.

If you see this message, it's almost certainly an internal bug, so make sure to
get in contact so the issue can be fixed.