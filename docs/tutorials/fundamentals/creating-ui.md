Now that we have Fusion up and running, let's learn how to create instances
from a script quickly and neatly.

??? abstract "Required code"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)
	```

-----

## Instances from Code

In Fusion, you create all of your UI instances from code. That might sound
counterproductive, but it will soon allow you to easily reuse your UI components
and leverage powerful tools for connecting your UI and game scripts together.

To make the experience more pleasant, Fusion introduces an alternative to
`Instance.new` which lets you construct entire instances in one go - called the
`New` function.

Here's an example code snippet using `New` - you can compare it to `Instance.new`:

=== "New"

	```Lua
	local myPart = New "Part" {
		Parent = workspace,

		Position = Vector3.new(1, 2, 3),
		BrickColor = BrickColor.new("Bright green"),
		Size = Vector3.new(2, 1, 4)
	}
	```

=== "Instance.new"

	```Lua
	local myPart = Instance.new("Part")

	myPart.Position = Vector3.new(1, 2, 3)
	myPart.BrickColor = BrickColor.new("Bright green")
	myPart.Size = Vector3.new(2, 1, 4)

	myPart.Parent = workspace
	```

!!! note
	You don't need parentheses `()` for `New` - just type the class name and
	properties like we did above.

In the above code snippet, the `New` function:

- creates a new part
- gives it a position, size and colour
- parents it to the workspace
- returns the part, so it can be stored in `myPart`

The `New` function has many more features built in, which you'll use later, but
for now we'll just use it to set properties.

-----

## Making A ScreenGui

Let's use the `New` function to create a ScreenGui.

We're going to put it in our PlayerGui, so we need to import the `Players`
service:

```Lua linenums="1" hl_lines="2"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Fusion = require(ReplicatedStorage.Fusion)
```

We'll also need to import `New` from Fusion:

```Lua linenums="1" hl_lines="5"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Fusion = require(ReplicatedStorage.Fusion)

local New = Fusion.New
```

Now, we can use the `New` function like we did in the snippet above. We want to
create a ScreenGui with a name of 'MyFirstGui' parented to our PlayerGui.

The following code snippet does all of this for us:

```Lua linenums="1" hl_lines="7-13"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Fusion = require(ReplicatedStorage.Fusion)

local New = Fusion.New

local gui = New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	Name = "MyFirstGui"
}
```

If you press 'Play', you should see that a ScreenGui has appeared in your
PlayerGui, with all of the properties we've set:

![Explorer screenshot](MyFirstGui.png)

Hopefully you're getting comfortable with this syntax - we'll expand on it in
the next section.

??? tip
	Fusion automatically applies some 'sensible default' properties for
	you, so you don't have to specify them. Here, `ZIndexBehavior` will
	default to 'false' and `ResetOnSpawn` defaults to `false`.
	[You can see a list of all default properties here.](https://elttob.github.io/Fusion/api-reference/api/new/#default-properties)

-----

## Adding a Child

Let's now add a TextLabel with a message and parent it to our ScreenGui.

To help with this, the `New` function lets us add children directly to our
instance. In order to use this feature, we first need to import `Children` from
Fusion:

```Lua linenums="1" hl_lines="6"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Fusion = require(ReplicatedStorage.Fusion)

local New = Fusion.New
local Children = Fusion.Children

```

Now, we can make any instance a child of our ScreenGui - just pass it in using
`#!Lua [Children]` as the key.

For example, here we're creating our TextLabel, and adding it as a child:

```Lua linenums="8" hl_lines="8-14"
local gui = New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	Name = "MyFirstGui",
	ResetOnSpawn = false,
	ZIndexBehavior = "Sibling",

	[Children] = New "TextLabel" {
		Position = UDim2.fromScale(.5, .5),
		AnchorPoint = Vector2.new(.5, .5),
		Size = UDim2.fromOffset(200, 50),

		Text = "Fusion is fun :)"
	}
}
```

If you press 'Play' now, you should see a TextLabel in the centre of your screen:

![Final result](FinalResult.png)

-----

## Multiple Children

You can add more than one instance - `Children` supports arrays of instances.

If we wanted multiple TextLabels, we can create an array to hold our children:

```Lua linenums="8" hl_lines="8 16"
local gui = New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	Name = "MyFirstGui",
	ResetOnSpawn = false,
	ZIndexBehavior = "Sibling",

	[Children] = {
		New "TextLabel" {
			Position = UDim2.fromScale(.5, .5),
			AnchorPoint = Vector2.new(.5, .5),
			Size = UDim2.fromOffset(200, 50),

			Text = "Fusion is fun :)"
		}
	}
}
```

Now, we can add another TextLabel to the array, and it will also be parented:

```Lua linenums="8" hl_lines="17-23"
local gui = New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	Name = "MyFirstGui",
	ResetOnSpawn = false,
	ZIndexBehavior = "Sibling",

	[Children] = {
		New "TextLabel" {
			Position = UDim2.fromScale(.5, .5),
			AnchorPoint = Vector2.new(.5, .5),
			Size = UDim2.fromOffset(200, 50),

			Text = "Fusion is fun :)"
		},

		New "TextLabel" {
			Position = UDim2.new(.5, 0, .5, 50),
			AnchorPoint = Vector2.new(.5, .5),
			Size = UDim2.fromOffset(200, 50),

			Text = "Two is better than one!"
		}
	}
}
```

If you press 'Play', you should see both TextLabels appear:

![Final result with many messages](FinalResult-Many.png)

-----

Congratulations - you've now learned how to create simple instances with Fusion!
Over the course of the next few tutorials, you'll see this syntax being used a
lot, so you'll have some time to get used to it.

It's important to understand the basics of the `New` function, as it's used
throughout almost all Fusion code.

??? abstract "Finished code"
	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local Fusion = require(ReplicatedStorage.Fusion)

	local New = Fusion.New
	local Children = Fusion.Children

	local gui = New "ScreenGui" {
		Parent = Players.LocalPlayer.PlayerGui,

		Name = "MyFirstGui",
		ResetOnSpawn = false,
		ZIndexBehavior = "Sibling",

		[Children] = {
			New "TextLabel" {
				Position = UDim2.fromScale(.5, .5),
				AnchorPoint = Vector2.new(.5, .5),
				Size = UDim2.fromOffset(200, 50),

				Text = "Fusion is fun :)"
			},

			New "TextLabel" {
				Position = UDim2.new(.5, 0, .5, 50),
				AnchorPoint = Vector2.new(.5, .5),
				Size = UDim2.fromOffset(200, 50),

				Text = "Two is better than one!"
			}
		}
	}

	```
