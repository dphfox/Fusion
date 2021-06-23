You've learned how UIs work with `New`, and you've seen how state management
works with `State` and `Computed`. Ready to fuse them into one unified script?

-----

## Where We Left Off

We're going to be returning to our first LocalScript for this tutorial - it's
okay to delete the script from last time if you're done with it.

For reference, here's where we left off:

```Lua linenums="1"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange

local gui = New "ScreenGui" {
	Parent = game:GetService("Players").LocalPlayer.PlayerGui,

	Name = "MyFirstGui",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

	[Children] = New "TextBox" {
		Position = UDim2.fromScale(.5, .5),
		AnchorPoint = Vector2.new(.5, .5),
		Size = UDim2.fromOffset(200, 50),

		Text = "",
		ClearTextOnFocus = false,

		[OnChange "Text"] = function(newText)
			print(newText)
		end
	}
}
```

Before we get started, we need to import `State` and `Computed`, so we can use
it later:

```Lua linenums="1" hl_lines="4-5"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Fusion)

local State = Fusion.State
local Computed = Fusion.Computed

local New = Fusion.New
```

Awesome - we're ready to begin.

-----

## Building A Counting Button

We're going to modify our script to create a simple counting button. Every time
we click the button, it'll show how many times we've clicked it so far.

Firstly, let's switch out our TextBox for a TextButton, and clean out some old
properties we don't need anymore. Don't worry about the Text property for now -
we'll come back to that later.

```Lua linenums="12" hl_lines="8-12"
local gui = New "ScreenGui" {
	Parent = game:GetService("Players").LocalPlayer.PlayerGui,

	Name = "MyFirstGui",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

	[Children] = New "TextButton" {
		Position = UDim2.fromScale(.5, .5),
		AnchorPoint = Vector2.new(.5, .5),
		Size = UDim2.fromOffset(200, 50)
	}
}
```

Next, we'll set up an event handler, to detect when the user clicks our button:

```Lua linenums="12" hl_lines="13-15"
local gui = New "ScreenGui" {
	Parent = game:GetService("Players").LocalPlayer.PlayerGui,

	Name = "MyFirstGui",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

	[Children] = New "TextButton" {
		Position = UDim2.fromScale(.5, .5),
		AnchorPoint = Vector2.new(.5, .5),
		Size = UDim2.fromOffset(200, 50),

		[OnEvent "Activated"] = function()
			--TODO: count clicks
		end
	}
}
```

Now, we need to introduce some state to our script. Just above our UI code,
we'll add a `counter` state object, which will store how many clicks the button
has recieved:

```Lua linenums="12" hl_lines="1"
local counter = State(0)

local gui = New "ScreenGui" {
	Parent = game:GetService("Players").LocalPlayer.PlayerGui,

	Name = "MyFirstGui",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

	[Children] = New "TextButton" {
		Position = UDim2.fromScale(.5, .5),
		AnchorPoint = Vector2.new(.5, .5),
		Size = UDim2.fromOffset(200, 50),

		[OnEvent "Activated"] = function()
			--TODO: count clicks
		end
	}
}
```

Now, back in our event handler, we can increment the counter on every click by
getting the value of `counter`, adding 1, then setting the value again:

```Lua linenums="12" hl_lines="16"
local counter = State(0)

local gui = New "ScreenGui" {
	Parent = game:GetService("Players").LocalPlayer.PlayerGui,

	Name = "MyFirstGui",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

	[Children] = New "TextButton" {
		Position = UDim2.fromScale(.5, .5),
		AnchorPoint = Vector2.new(.5, .5),
		Size = UDim2.fromOffset(200, 50),

		[OnEvent "Activated"] = function()
			counter:set(counter:get() + 1)
		end
	}
}
```

Cool - we can now count clicks!

-----

## Linking Instances And State

Our last problem is displaying a message. How do we dynamically set the Text
property on our TextButton?

The answer is stunningly simple. `New` has yet another trick up its sleeve - you
can set a property to a State or Computed, and it'll just work. Let's try it:

```Lua linenums="12" hl_lines="15"
local counter = State(0)

local gui = New "ScreenGui" {
	Parent = game:GetService("Players").LocalPlayer.PlayerGui,

	Name = "MyFirstGui",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

	[Children] = New "TextButton" {
		Position = UDim2.fromScale(.5, .5),
		AnchorPoint = Vector2.new(.5, .5),
		Size = UDim2.fromOffset(200, 50),

		Text = counter,

		[OnEvent "Activated"] = function()
			counter:set(counter:get() + 1)
		end
	}
}
```

No messing around with updating properties manually or anything!
Try it out by pressing 'Play' - click the button a few times, and the text will
update in real time:

![Button showing counter state](/images/tutorials/learning-fusion/putting-it-all-together/Counting-Plain.png)

This is fantastic, but that number looks a bit lonely. How could we add some
extra text?

That's also simple to do - we'll just make the Text property derive from
`counter` using a Computed object:

```Lua linenums="12" hl_lines="15-21"
local counter = State(0)

local gui = New "ScreenGui" {
	Parent = game:GetService("Players").LocalPlayer.PlayerGui,

	Name = "MyFirstGui",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

	[Children] = New "TextButton" {
		Position = UDim2.fromScale(.5, .5),
		AnchorPoint = Vector2.new(.5, .5),
		Size = UDim2.fromOffset(200, 50),

		Text = Computed(function()
			if counter:get() == 0 then
				return "Click me!"
			else
				return "You've clicked " .. counter:get() .. " time(s)."
			end
		end),

		[OnEvent "Activated"] = function()
			counter:set(counter:get() + 1)
		end
	}
}
```

Just like magic, our number now has some much-needed context!

![Button showing counter with extra text](/images/tutorials/learning-fusion/putting-it-all-together/Counting-Final.png)

-----

If you've reached this point, congratulations! You now know the fundamentals of
building UI and managing state using Fusion, and you're ready to move on to
higher-level concepts and tutorials.

While you're here, though, why not play around with your button for a bit? See
if you can make it look nicer; feel free to dabble with adding extra instances
such as UIStroke or UICorner:

![Button with modified styles](/images/tutorials/learning-fusion/putting-it-all-together/Improved-Button.png)

