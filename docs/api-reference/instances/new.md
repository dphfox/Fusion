<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">Instances</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-code-24:</span>
	<span class="fusiondoc-api-name">New</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">function</span>
		<span class="fusiondoc-api-pill-since">since v0.1</span>
	</span>
</h1>

Given a class name, returns a [component](./component.md) which creates
instances of that class. The property table may specify properties to set on the
instance, or include [special keys](./specialkey.md) for more advanced
operations.

```Lua
(className: string) -> Component
```

-----

## Parameters

- `className` - the instance class that should be created

-----

## Returns

A component function. When called, it creates a new instance of the given class,
populates it using the property table, and returns it.

-----

## Example Usage

```Lua
local myButton: TextButton = New "TextButton" {
	Parent = Players.LocalPlayer.PlayerGui,

	Position = UDim2.fromScale(.5, .5),
	AnchorPoint = Vector2.new(.5, .5),
	Size = UDim2.fromOffset(200, 50),

	Text = "Hello, world!",

	[OnEvent "Activated"] = function()
		print("The button was clicked!")
	end,

	[OnChange "Name"] = function(newName)
		print("The button was renamed to:", newName)
	end,

	[Children] = New "UICorner" {
		CornerRadius = UDim.new(0, 8)
	}
}
```

-----

## Property Table Processing

The `props` table uses a mix of string and special keys to specify attributes of
the instance which should be set.

String keys are treated as property declarations - values passed in will be set
upon the instance:

```Lua
local example = New "Part" {
	-- sets the Position property
	Position = Vector3.new(1, 2, 3)
}
```

Passing a state object to a string key will bind the property value; when the
value of the object changes, the property will update to match on the next
resumption step:

```Lua
local myName = State("Bob")

local example = New "Part" {
	-- initially, the Name will be set to Bob
	Name = myName
}

-- change the state object to store "John"
-- on the next resumption step, the part's Name will change to John
myName:set("John")
```

Special keys, such as [Children](../children) or [OnEvent](../onevent), may also
be used as keys in the property table. For more information about how special
keys work, [see the SpecialKey page.](../../types/specialkey)

-----

## Default Properties

The `New` function provides its own set of 'sensible default' property values
for some class types, which will be used in place of Roblox defaults. This is
done to opt out of some legacy features and unhelpful defaults.

[You can see the default properties Fusion uses here.](https://github.com/Elttob/Fusion/blob/main/src/Instances/defaultProps.lua)