```Lua
function New(className: string): (props: {[string | Symbol]: any}) -> Instance
```

Constructs and returns a new instance, with options for setting properties,
event handlers and other attributes on the instance right away.

The function has curried parameters - when calling `New` with the `className`
parameter, it'll return a second function accepting the `props` parameter. This
is done to take advantage of some function call syntax sugar in Lua:

```Lua
local myInstance = New("Frame")({...})
-- is equivalent to:
local myInstance = New "Frame" {...}
```

!!! warning "Instance cleanup"
	Make sure to destroy your instances properly. Without using an explicit
	`:Destroy()`, it's easy to accidentally introduce memory leaks.

	For lists of instances, you can use [ComputedPairs](../computedpairs), which
	comes with good defaults for instance caching and cleanup.

-----

## Parameters

- `className: string` - the class type of instance to create
- `props: {[string | Symbol]: any}` - a table of properties, event handlers and
other attributes to apply to the instance

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

## Passing In Properties

The `props` table uses a mix of string and symbol keys to specify attributes of
the instance which should be set.

String keys are treated as property declarations - values passed in will be set
upon the instance:

```Lua
local example = New "Part" {
	-- sets the Position property
	Position = Vector3.new(1, 2, 3)
}
```

Additionally, passing in [state objects](api-reference/state.md) or
[computed objects](api-reference/computed.md) will bind the property value; when
the value of the object changes, the property will also update on the next render
step:

```Lua
local myName = State("Bob")

local example = New "Part" {
	-- initially, the Name will be set to Bob
	Name = myName
}

-- change the state object to store "John"
-- on the next render step, the part's Name will change to John
myName:set("John")
```

Fusion provides additional symbol keys for other, specialised purposes - see
their documentation for more info on how each one works:

- [Children](../children) - parents other instances into this
instance
- [OnEvent](../onevent) - connects a callback to an event on
this instance
- [OnChange](../onchange) - connects a callback to the
`GetPropertyChangedSignal` event for a property on this instance

-----

## Default Properties

The `New` function provides its own set of 'sensible default' property values
for some class types, which will be used in place of Roblox defaults. This is
done to opt out of some legacy features and unhelpful defaults.

You can see the default properties Fusion uses here:

??? note "Default properties"
	```Lua
	ScreenGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = "Sibling"
	},

	BillboardGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = "Sibling"
	},

	SurfaceGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = "Sibling",

		SizingMode = "PixelsPerStud",
		PixelsPerStud = 50
	},

	Frame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0
	},

	ScrollingFrame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		ScrollBarImageColor3 = Color3.new(0, 0, 0)
	},

	TextLabel = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		Font = "SourceSans",
		Text = "",
		TextColor3 = Color3.new(0, 0, 0),
		TextSize = 14
	},

	TextButton = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		AutoButtonColor = false,

		Font = "SourceSans",
		Text = "",
		TextColor3 = Color3.new(0, 0, 0),
		TextSize = 14
	},

	TextBox = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		ClearTextOnFocus = false,

		Font = "SourceSans",
		Text = "",
		TextColor3 = Color3.new(0, 0, 0),
		TextSize = 14
	},

	ImageLabel = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0
	},

	ImageButton = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		AutoButtonColor = false
	},

	ViewportFrame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0
	},

	VideoFrame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0
	}
	```