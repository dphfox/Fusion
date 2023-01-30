If your code isn't working properly, or if Fusion is malfunctioning, you may see
some errors being printed to the output. Each message comes with a unique ID at
the end.

On this page, you can learn more about any error messages you're receiving.

-----

## `cannotAssignProperty`

```
The class type 'Foo' has no assignable property 'Bar'.
```

This message shows if you try to assign a non-existent or locked property using
the [New](../new) function:

```Lua
local folder = New "Folder" {
	DataCost = 12345,
	ThisPropertyDoesntExist = "Example"
}
```

!!! tip
	Different scripts may have different privileges - for example, plugins will
	be allowed more privileges than in-game scripts. Make sure you have the
	necessary privileges to assign to your properties!

-----

## `cannotConnectChange`

```
The Frame class doesn't have a property called 'Foo'.
```

This message shows if you try to connect a handler to a non-existent property
change event when using the [New](../new) function:

```Lua
local textBox = New "TextBox" {
	[OnChange "ThisPropertyDoesntExist"] = function()
		...
	end)
}
```

-----

## `cannotConnectEvent`

```
The Frame class doesn't have an event called 'Foo'.
```

This message shows if you try to connect a handler to a non-existent event when
using the [New](../new) function:

```Lua
local button = New "TextButton" {
	[OnEvent "ThisEventDoesntExist"] = function()
		...
	end)
}
```

-----

## `cannotCreateClass`

```
Can't create a new instance of class 'Foo'.
```

This message shows when using the [New](../new) function with an invalid class
type:

```Lua
local instance = New "ThisClassTypeIsInvalid" {
	...
}
```

-----

## `computedCallbackError`

```
Computed callback error: attempt to index a nil value
```

This message shows when the callback of a [computed object](../computed)
encounters an error:

```Lua
local example = Computed(function()
	local badMath = 2 + "fish"
end)
```

-----

## `invalidSpringDamping`

```
The damping ratio for a spring must be >= 0. (damping was -0.50)
```

This message shows if you try to provide a damping ratio to a [spring](../spring)
which is less than 0:

```Lua
local speed = 10
local damping = -12345
local spring = Spring(state, speed, damping)
```

Damping ratio must always be between 0 and infinity for a spring to be
physically simulatable.

-----

## `invalidSpringSpeed`

```
The speed of a spring must be >= 0. (speed was -2.00)
```

This message shows if you try to provide a speed to a [spring](../spring) which
is less than 0:

```Lua
local speed = -12345
local spring = Spring(state, speed)
```

Since a speed of 0 is equivalent to a spring that doesn't move, any slower speed
is not simulatable or physically sensible.

-----

## `mistypedSpringDamping`

```
The damping ratio for a spring must be a number. (got a boolean)
```

This message shows if you try to provide a damping ratio to a [spring](../spring)
which isn't a number:

```Lua
local speed = 10
local damping = true
local spring = Spring(state, speed, damping)
```

-----

## `mistypedSpringSpeed`

```
The speed of a spring must be a number. (got a boolean)
```

This message shows if you try to provide a speed to a [spring](../spring) which
isn't a number:

```Lua
local speed = true
local spring = Spring(state, speed)
```

-----

## `mistypedTweenInfo`

```
The tween info of a tween must be a TweenInfo. (got a boolean)
```

This message shows if you try to provide a tween info to a [tween](../tween)
which isn't a TweenInfo:

```Lua
local tweenInfo = true
local tween = Tween(state, tweenInfo)
```

-----

## `pairsDestructorError`

```
ComputedPairs destructor error: attempt to index a nil value
```

This message shows when the `destructor` callback of a [ComputedPairs object](../computedpairs)
encounters an error:

```Lua
local example = ComputedPairs(
	data,
	processor,
	function(value)
		local badMath = 2 + "fish"
	end
)
```

-----

## `pairsProcessorError`

```
ComputedPairs callback error: attempt to index a nil value
```

This message shows when the `processor` callback of a [ComputedPairs object](../computedpairs)
encounters an error:

```Lua
local example = ComputedPairs(data, function(key, value)
	local badMath = 2 + "fish"
end)
```

-----

## `springTypeMismatch`

```
The type 'number' doesn't match the spring's type 'Color3'.
```

Some methods on [spring](../spring) objects require incoming values to match
the types previously being used on the spring.

This message shows when an incoming value doesn't have the same type as values
used previously on the spring:

```Lua
local colour = State(Color3.new(1, 0, 0))
local colourSpring = Spring(colour)

colourSpring:addVelocity(Vector2.new(2, 3))
```

-----

## `strictReadError`

```
'Foo' is not a valid member of 'Bar'.
```

In Fusion, some tables may have strict reading rules. This is typically used on
public APIs as a defense against typos.

This message shows when trying to read a non-existent member of these tables.

-----

## `unknownMessage`

```
Unknown error: attempt to index a nil value
```

If you see this message, it's almost certainly an internal bug, so make sure to
get in contact so the issue can be fixed.

When Fusion code attempts to log a message, warning or error, it needs to
provide an ID. This ID is used to show the correct message, and serves as a
simple, memorable identifier if you need to look up the message later.
However, if that code provides an invalid ID, then the message will be replaced
with this one.

-----

## `unrecognisedChildType`

```
'number' type children aren't accepted as children in `New`.
```

This message shows when attempting to pass something as a child which isn't an
instance, table of instances, or state object containing an instance (when using
the [New](../new.md) function):

```Lua
local instance = New "Folder" {
	[Children] = {
		1, 2, 3, 4, 5,

		{true, false},

		State(Enum.Material.Grass)
	}
}
```

!!! note
	Note that state objects are allowed to store `nil` to represent the absence
	of an instance, as an exception to these rules.

-----

## `unrecognisedPropertyKey`

```
'number' keys aren't accepted in the property table of `New`.
```

When you create an instance in Fusion using [New](../new),
you can pass in a 'property table' containing properties, children, event and
property change handlers, etc.

This table is only expected to contain keys of two types:

- string keys, e.g. `#!Lua Name = "Example"`
- a few symbol keys, e.g. `#!Lua [OnEvent "Foo"] = ...`

This message shows if Fusion finds a key of a different type, or if the key
isn't one of the few symbol keys used in New:

```Lua
local folder = New "Folder" {
	[Vector3.new()] = "Example",

	"This", "Shouldn't", "Be", "Here"
}
```