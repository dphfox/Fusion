Now that we can create instances, let's learn how to handle events and property
changes.

??? abstract "Required code"

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
			New "TextButton" {
				Position = UDim2.new(0.5, 0, 0.5, -100),
				AnchorPoint = Vector2.new(.5, .5),
				Size = UDim2.fromOffset(200, 50),

				Text = "Click me!"
			},

			New "TextBox" {
				Position = UDim2.new(0.5, 0, 0.5, 100),
				AnchorPoint = Vector2.new(.5, .5),
				Size = UDim2.fromOffset(200, 50),

				Text = "",
				ClearTextOnFocus = false
			}
		}
	}

	```

-----

## Connecting to Events

Inside the code from above, you'll notice a TextButton. Let's try to connect to
it's `Activated` event to detect mouse clicks.

To help with this, `New` allows us to add event handlers on our instance directly.
In order to use this feature, we need to import `OnEvent` from Fusion:

```Lua linenums="1" hl_lines="7"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Fusion = require(ReplicatedStorage.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
```

Now you can pass in event handling functions by using `#!Lua [OnEvent "EventName"]`
as the key.

As an example, here we're connecting a function to our TextButton's `Activated`
event:

```Lua linenums="14" hl_lines="11-13"
	ZIndexBehavior = "Sibling",

	[Children] = {
		New "TextButton" {
			Position = UDim2.fromScale(.5, .5),
			AnchorPoint = Vector2.new(.5, .5),
			Size = UDim2.fromOffset(200, 50),

			Text = "Fusion is fun :)",

			[OnEvent "Activated"] = function(...)
				print("Clicked!", ...)
			end
		},

		New "TextBox" {
            Position = UDim2.new(0.5, 0, 0.5, 100),
```

This works just like a regular `:Connect()` - you'll recieve all the arguments
from the event. Here, we're just printing them out for demonstration purposes.

If you press 'Play' and click the button a few times, you should see something
like this in the output:

![Event handler output](Clicked-Output.png)

That's all there is to event handling! Fusion will manage the event connections
for you automatically.

-----

## Responding to Change

In addition to regular events, you can listen to property change events (the
events returned by `GetPropertyChangedSignal`).

In order to use property change events, you'll need to import `OnChange`:

```Lua linenums="1" hl_lines="8"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Fusion = require(ReplicatedStorage.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
```

Now you can pass in functions using `#!Lua [OnChange "PropertyName"]` as the key.
When the property is changed, your function will be called with the new value as
the only argument.

To demonstrate this, here we're printing the text in our TextBox whenever it
changes:

```Lua linenums="25" hl_lines="14-16"
			[OnEvent "Activated"] = function(...)
				print("Clicked!", ...)
			end
		},

		New "TextBox" {
			Position = UDim2.new(0.5, 0, 0.5, 100),
			AnchorPoint = Vector2.new(.5, .5),
			Size = UDim2.fromOffset(200, 50),

			Text = "",
			ClearTextOnFocus = false,

			[OnChange "Text"] = function(newText)
				print(newText)
			end
		}
	}
}
```

Now, if you press 'Play' and start typing into the TextBox, you should see the
TextBox's contents being printed to the output for each character you type:

![Property change handler output](Typing-Output.png)

-----

With that, you've covered everything there is to know about event and property
change handlers! In later tutorials, this will be useful for responding to user
input.

??? abstract "Finished code"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local Fusion = require(ReplicatedStorage.Fusion)

	local New = Fusion.New
	local Children = Fusion.Children
	local OnEvent = Fusion.OnEvent
	local OnChange = Fusion.OnChange

	local gui = New "ScreenGui" {
		Parent = Players.LocalPlayer.PlayerGui,

		Name = "MyFirstGui",
		ResetOnSpawn = false,
		ZIndexBehavior = "Sibling",

		[Children] = {
			New "TextButton" {
				Position = UDim2.new(0.5, 0, 0.5, -100),
				AnchorPoint = Vector2.new(.5, .5),
				Size = UDim2.fromOffset(200, 50),

				Text = "Click me!",

				[OnEvent "Activated"] = function(...)
					print("Clicked!", ...)
				end
			},

			New "TextBox" {
				Position = UDim2.new(0.5, 0, 0.5, 100),
				AnchorPoint = Vector2.new(.5, .5),
				Size = UDim2.fromOffset(200, 50),

				Text = "",
				ClearTextOnFocus = false,

				[OnChange "Text"] = function(newText)
					print(newText)
				end
			}
		}
	}

	```