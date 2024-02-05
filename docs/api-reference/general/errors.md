<nav class="fusiondoc-api-breadcrumbs">
	<span>General</span>
	<span>Errors</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-x-circle-24:</span>
	<span class="fusiondoc-api-name">Errors</span>
</h1>

Whenever Fusion outputs any errors or messages to the console, it will have a
short error ID at the end. This is used to uniquely identify what kind of error
or message you're seeing.

Use the search box below to paste in or type an error ID, and it will scroll to
the details for you.

<input
	id="fusiondoc-error-paste-box"
	class="md-input md-input--stretch"
	placeholder="Type or paste an error ID here..."
/>

<script src="./error-paste-box.js" defer></script>

-----

<div class="fusiondoc-error-api-section" markdown>

## cannotAssignProperty

```
The class type 'Foo' has no assignable property 'Bar'.
```

**Related to:**
[`New`](../../instances/members/new),
[`Hydrate`](../../instances/members/hydrate)

This message means you tried to set a property on an instance, but the property
can't be assigned to. This could be because the property doesn't exist, or
because it's locked by Roblox to prevent edits.

!!! warning "Check your privileges"
	Different scripts may have different privileges - for example, plugins will
	be allowed more privileges than in-game scripts. Make sure you have the
	necessary privileges to assign to your properties!
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## cannotConnectChange

```
The Frame class doesn't have a property called 'Foo'.
```

**Related to:**
[`OnChange`](../../instances/members/onchange)

This message means you tried to connect to a property change event, but the
property you specify doesn't exist on the instance.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## cannotConnectEvent

```
The Frame class doesn't have an event called 'Foo'.
```

**Related to:**
[`OnEvent`](../../instances/members/onevent)

This message means you tried to connect to an event on an instance, but the
event you specify doesn't exist on the instance.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## cannotCreateClass

```
Can't create a new instance of class 'Foo'.
```

**Related to:**
[`New`](../../instances/members/new)

This message means you tried to create a new instance type, but that type of
instance could not be created, or doesn't exist in Roblox.

Check that you spelled the class name correctly.

!!! warning "Some instances are not available outside of testing"
	Sometimes, Roblox will lock new instance types behind beta tests or FFlags,
	so if you're using bleeding-edge or unreleased features, ensure you're
	enrolled in the correct beta tests, using the correct Roblox Studio
	update channel, and have the correct flags configured locally.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## callbackError

```
Callback error: attempt to index a nil value
```

This message means you provided a callback to Fusion, but it ran into an error.
For example, a [computed object](../state/computed) might have failed to compute
a value.

Review the stack trace that came with the error to see what part of the code
may have caused the error.

```Lua
local example = Computed(function()
	local badMath = 2 + "fish"
end)
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## forKeyCollision

```
ForKeys should only write to output key 'Charlie' once when processing key changes, but it wrote to it twice. Previously input key: 'Alice'; New input key: 'Bob'
```

This message means you returned the same value twice for two different keys in
a [ForKeys object](../state/forkeys).

```Lua
local data = {
	Alice = true,
	Bob = true
}
local example = ForKeys(data, function(key)
	if key == "Alice" or key == "Bob" then
		return "Charlie"
	end
end)
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## forProcessorError

```
ForKeys callback error: attempt to index a nil value
```

This message means the callback of a [ForKeys object](../state/forkeys)
encountered an error.

```Lua
local example = ForKeys(array, function(key)
	local badMath = 2 + "fish"
end)
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidChangeHandler

```
The change handler for the 'Text' property must be a function.
```

This message means you tried to use [OnChange](../instances/onchange) on an
instance's property, but instead of passing a function callback, you passed
something else.

```Lua
local input = New "TextBox" {
	[OnChange "Text"] = "lemons"
}
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidAttributeChangeHandler

```
The change handler for the 'Ammo' attribute must be a function.
```

This message means you tried to use [AttributeChange](../instances/attributechange) on an
instance's attribute, but instead of passing a function callback, you passed
something else.

```Lua
local config = New "Configuration" {
	[AttributeChange "Ammo"] = "guns"
}
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidEventHandler

```
The handler for the 'Activated' event must be a function.
```

This message means you tried to use [OnEvent](../instances/onevent) on an
instance's event, but instead of passing a function callback, you passed
something else.

```Lua
local button = New "TextButton" {
	[OnEvent "Activated"] = "limes"
}
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidPropertyType

```
'Frame.Size' expected a 'UDim2' type, but got a 'Color3' type.
```

This message means you tried to set a property on an instance, but you gave it
the wrong type of value.

This usually occurs with the [New](../instances/new) or
[Hydrate](../instances/hydrate) functions:

```Lua
local ui = New "Frame" {
	Size = Computed(function()
		return Color3.new(1, 0, 0)
	end)
}
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidRefType

```
Instance refs must be Value objects.
```

This message means you tried to use [Ref](../instances/ref), but you didn't also
give it a [value object](../state/value) to store the instance inside of.

```Lua
local thing = New "Part" {
	[Ref] = 2
}
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidOutType

```
[Out] properties must be given Value objects.
```

This message means you tried to use [Out](../instances/out), but you didn't also
give it a [value object](../state/value) to store the property's value inside
of.

```Lua
local thing = New "Part" {
	[Out "Color"] = true
}
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidAttributeOutType

```
[AttributeOut] properties must be given Value objects.
```

This message means you tried to use [AttributeOut](../instances/attributeout), but you didn't also
give it a [value object](../state/value) to store the attributes's value inside
of.

```Lua
local config = New "Configuration" {
	[AttributeChange "Ammo"] = "guns"
}
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidOutProperty

```
The Part class doesn't have a property called 'Flobulator'.
```

This message means you tried to read a property of an instance using
[Out](../instances/out), but the property can't be read. This could be because
the property doesn't exist, or because it's locked by Roblox to prevent reading.

```Lua
local value = Value()

local thing = New "Part" {
	[Out "Flobulator"] = value
}
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidSpringDamping

```
The damping ratio for a spring must be >= 0. (damping was -0.50)
```

This message means you gave a damping ratio to a [spring object](../animation/spring)
which is less than 0:

```Lua
local speed = 10
local damping = -12345
local spring = Spring(state, speed, damping)
```

Damping ratio must always be between 0 and infinity for a spring to be
physically simulatable.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## invalidSpringSpeed

```
The speed of a spring must be >= 0. (speed was -2.00)
```

This message means you gave a speed to a [spring object](../animation/spring)
which is less than 0:

```Lua
local speed = -12345
local spring = Spring(state, speed)
```

Since a speed of 0 is equivalent to a spring that doesn't move, any slower speed
is not simulatable or physically sensible.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## mistypedSpringDamping

```
The damping ratio for a spring must be a number. (got a boolean)
```

This message means you gave a damping ratio to a [spring object](../animation/spring)
which isn't a number.

```Lua
local speed = 10
local damping = true
local spring = Spring(state, speed, damping)
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## mistypedSpringSpeed

```
The speed of a spring must be a number. (got a boolean)
```

This message means you gave a speed to a [spring object](../animation/spring)
which isn't a number.

```Lua
local speed = true
local spring = Spring(state, speed)
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## mistypedTweenInfo

```
The tween info of a tween must be a TweenInfo. (got a boolean)
```

This message shows if you try to provide a tween info to a [tween](../animation/tween)
which isn't a TweenInfo:

```Lua
local tweenInfo = true
local tween = Tween(state, tweenInfo)
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## noTaskScheduler

```
Fusion is not connected to an external task scheduler.
```

This message shows when Fusion attempts to schedule something for execution
without first setting a task scheduler for the library to use.

For users of Fusion on Roblox, this generally shouldn't occur as Fusion should
automatically be bound to Roblox's task scheduler. However, when using Fusion
in other environments, the fix is to provide Fusion with all the task scheduler
callbacks necessary to schedule tasks for execution in the future.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## springTypeMismatch

```
The type 'number' doesn't match the spring's type 'Color3'.
```

Some methods on [spring objects](../animation/spring) require incoming values to
match the types previously being used on the spring.

This message means you passed a value to one of those methods, but it wasn't the
same type as the type of the spring.

```Lua
local colour = State(Color3.new(1, 0, 0))
local colourSpring = Spring(colour)

colourSpring:addVelocity(Vector2.new(2, 3))
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## stateGetWasRemoved

```
`StateObject:get()` has been replaced by `use()` and `peek()` - see discussion #217 on GitHub.
```

This message means you attempted to call the now-removed `:get()` method on a
[state object](../state/stateobject.md). Starting with Fusion 0.3, this method
has been removed in favour of the [peek function](../state/peek.md) and
[use callbacks](../state/use.md).

[Learn more by visiting this discussion on GitHub.](https://github.com/Elttob/Fusion/discussions/217)

```Lua
local value = Value(5)
print(value:get()) -- should be print(peek(value))
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## unknownMessage

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
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## unrecognisedChildType

```
'number' type children aren't accepted as children in `New`.
```

This message means you tried to pass something to [Children](../instances/children.md)
which isn't a valid [child](../instances/child.md). This usually means that you
passed something that isn't an instance, array or [state object](../state/stateobject.md).

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
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## unrecognisedPropertyKey

```
'number' keys aren't accepted in the property table of `New`.
```

This message means, while using [New](../instances/new) or [Hydrate](../instances/hydrate),
you specified something in the property table that's not a property name or
[special key](../instances/specialkey).

Commonly, this means you accidentally specified children directly inside of
the property table, rather than using the dedicated [Children](../instances/children.md)
special key.

```Lua
local folder = New "Folder" {
	[Vector3.new()] = "Example",

	"This", "Shouldn't", "Be", "Here"
}
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>

## unrecognisedPropertyStage

```
'discombobulate' isn't a valid stage for a special key to be applied at.
```

Fusion provides a standard interface for defining [special keys](../instances/specialkey.md)
which can be used to extend the functionality of [New](../instances/new.md) or
[Hydrate](../instances/hydrate.md).

Within this interface, keys can select when they run using the `stage` field.
If an unexpected value is passed as the stage, then this error will be thrown
when attempting to use the key.

```Lua
local Example = {
	type = "SpecialKey",
	kind = "Example",
	stage = "discombobulate",
	apply = function() ... end
}

local folder = New "Folder" {
	[Example] = "foo"
}
```