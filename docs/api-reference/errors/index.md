<nav class="fusiondoc-api-breadcrumbs">
	<a href="..">Fusion</a>
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
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.1</span>
</p>

## cannotAssignProperty

```
The class type 'Foo' has no assignable property 'Bar'.
```

This message means you tried to set a property on an instance, but the property
can't be assigned to. This could be because the property doesn't exist, or
because it's locked by Roblox to prevent edits.

This usually occurs with the [New](../instances/new) or
[Hydrate](../instances/hydrate) functions:

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
</div>

-----

<div class="fusiondoc-error-api-section" markdown>
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.1</span>
</p>

## cannotConnectChange

```
The Frame class doesn't have a property called 'Foo'.
```

This message means you tried to connect to a property change event, but the
property you specify doesn't exist on the instance.

This usually occurs with the [New](../instances/new) or
[Hydrate](../instances/hydrate) functions:

```Lua
local textBox = New "TextBox" {
	[OnChange "ThisPropertyDoesntExist"] = function()
		...
	end)
}
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.1</span>
</p>

## cannotConnectEvent

```
The Frame class doesn't have an event called 'Foo'.
```

This message means you tried to connect to an event on an instance, but the
event you specify doesn't exist on the instance.

This usually occurs with the [New](../instances/new) or
[Hydrate](../instances/hydrate) functions:

```Lua
local button = New "TextButton" {
	[OnEvent "ThisEventDoesntExist"] = function()
		...
	end)
}
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.1</span>
</p>

## cannotCreateClass

```
Can't create a new instance of class 'Foo'.
```

This message means you tried to create a new instance type, but the type of
instance you specify doesn't exist in Roblox.

This usually occurs with the [New](../instances/new) function:

```Lua
local instance = New "ThisClassTypeIsInvalid" {
	...
}
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.1</span>
</p>

## computedCallbackError

```
Computed callback error: attempt to index a nil value
```

This message means the callback of a [computed object](../state/computed)
encountered an error.

```Lua
local example = Computed(function()
	local badMath = 2 + "fish"
end)
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

## destructorNeededComputed

```
To return instances from Computeds, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.
```

This message shows if you return destructible values from a
[computed object](../state/computed), without also specifying how to destroy
those values using a destructor.

[Learn more by visiting this discussion on GitHub.](https://github.com/Elttob/Fusion/discussions/183)

```Lua
local badComputed = Computed(function()
	return New "Folder" { ... }
end, nil)
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

## destructorNeededForKeys

```
To return instances from ForKeys, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.
```

This message shows if you return destructible values from a
[ForKeys object](../state/forkeys), without also specifying how to destroy
those values using a destructor.

[Learn more by visiting this discussion on GitHub.](https://github.com/Elttob/Fusion/discussions/183)

```Lua
local badForKeys = ForKeys(array, function(key)
	return New "Folder" { ... }
end, nil)
```

!!! note
	For some time during the development of v0.2, `ForKeys` would implicitly
	insert a destructor for you. This behaviour still works, but it's going to
	be removed in an upcoming version.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

## destructorNeededForPairs

```
To return instances from ForPairs, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.
```

This message shows if you return destructible values from a
[ForPairs object](../state/forpairs), without also specifying how to destroy
those values using a destructor.

[Learn more by visiting this discussion on GitHub.](https://github.com/Elttob/Fusion/discussions/183)

```Lua
local badForPairs = ForPairs(array, function(key, value)
	return key, New "Folder" { ... }
end, nil)
```

!!! note
	For some time during the development of v0.2, `ForPairs` would implicitly
	insert a destructor for you. This behaviour still works, but it's going to
	be removed in an upcoming version.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

## destructorNeededForValues

```
To return instances from ForValues, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.
```

This message shows if you return destructible values from a
[ForValues object](../state/forvalues), without also specifying how to destroy
those values using a destructor.

[Learn more by visiting this discussion on GitHub.](https://github.com/Elttob/Fusion/discussions/183)

```Lua
local badForValues = ForValues(array, function(value)
	return New "Folder" { ... }
end, nil)
```

!!! note
	For some time during the development of v0.2, `ForValues` would implicitly
	insert a destructor for you. This behaviour still works, but it's going to
	be removed in an upcoming version.
</div>

-----

<div class="fusiondoc-error-api-section" markdown>
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

## forKeysDestructorError

```
ForKeys destructor error: attempt to index a nil value
```

This message means the destructor passed to a [ForKeys object](../state/forkeys)
encountered an error.

```Lua
local function destructor(x)
	local badMath = 2 + "fish"
end

local example = ForKeys(array, doSomething, destructor)
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

## forKeysKeyCollision

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
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

## forKeysProcessorError

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
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

## forPairsDestructorError

```
ForPairs destructor error: attempt to index a nil value
```

This message means the destructor passed to a [ForPairs object](../state/forpairs)
encountered an error.

```Lua
local function destructor(x, y)
	local badMath = 2 + "fish"
end

local example = ForPairs(array, doSomething, destructor)
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

## forPairsKeyCollision

```
ForPairs should only write to output key 'Charlie' once when processing key changes, but it wrote to it twice. Previously input key: 'Alice'; New input key: 'Bob'
```

This message means you returned the same value twice for two different keys in
a [ForPairs object](../state/forpairs).

```Lua
local data = {
	Alice = true,
	Bob = true
}
local example = ForPairs(data, function(key, value)
	if key == "Alice" or key == "Bob" then
		return "Charlie", value
	end
end)
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

## forPairsProcessorError

```
ForPairs callback error: attempt to index a nil value
```

This message means the callback of a [ForPairs object](../state/forpairs)
encountered an error.

```Lua
local example = ForPairs(array, function(key, value)
	local badMath = 2 + "fish"
end)
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

## forValuesDestructorError

```
ForValues destructor error: attempt to index a nil value
```

This message means the destructor passed to a [ForValues object](../state/forvalues)
encountered an error.

```Lua
local function destructor(x)
	local badMath = 2 + "fish"
end

local example = ForValues(array, doSomething, destructor)
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

## forValuesProcessorError

```
ForValues callback error: attempt to index a nil value
```

This message means the callback of a [ForValues object](../state/forvalues)
encountered an error.

```Lua
local example = ForValues(array, function(value)
	local badMath = 2 + "fish"
end)
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

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
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

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
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

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
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

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
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

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
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

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
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.1</span>
</p>

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
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.1</span>
</p>

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
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.1</span>
</p>

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
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.1</span>
</p>

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
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.1</span>
</p>

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
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

## multiReturnComputed

```
Returning multiple values from Computeds is discouraged, as behaviour will change soon - see discussion #189 on GitHub.
```

This message means you returned more than one value from a [computed object](../state/computed).
There are two ways this could occur; either you're explicitly returning two
values (e.g. `return 1, 2`) or you're calling a function which returns two
values (e.g. `string.find`).

A simple fix is to surround your return expression with parentheses `()`, or to
save it into a variable before returning it.

[Learn more by visiting this discussion on GitHub.](https://github.com/Elttob/Fusion/discussions/189)

```Lua
local badComputed = Computed(function()
	return 1, 2, "foo", true
end, nil)
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

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
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.1</span>
</p>

## strictReadError

```
'thisDoesNotExist' is not a valid member of 'Fusion'.
```

This message means you tried to access something that doesn't exist. This
specifically occurs with a few 'locked' tables in Fusion, such as the table
returned by the module directly.

```Lua
local Foo = Fusion.thisDoesNotExist
```
</div>

-----

<div class="fusiondoc-error-api-section" markdown>
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.1</span>
</p>

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
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.1</span>
</p>

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
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.1</span>
</p>

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
<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

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