Using everything we've learned so far, let's build a complete UI to see how
Fusion's basic tools work together in a real project.

??? abstract "Required code"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local Fusion = require(ReplicatedStorage.Fusion)

	local New = Fusion.New
	local Children = Fusion.Children
	local OnEvent = Fusion.OnEvent

	local State = Fusion.State
	local Computed = Fusion.Computed
	```

-----

## Building The UI

We'll be creating a button which shows how many times you've clicked it - this
is often used as an introductory UI example for many libraries and frameworks
because it involves UI, event handling and state management together.

We'll start by creating a ScreenGui to contain our button:

```Lua linenums="1" hl_lines="12-17"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Fusion = require(ReplicatedStorage.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local State = Fusion.State
local Computed = Fusion.Computed

local gui = New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	Name = "CountingGui",
	ZIndexBehavior = "Sibling"
}

```

Next, we'll create a TextButton we can click, and a message TextLabel which will
eventually show how many clicks we've performed:

```Lua linenums="12" hl_lines="7-29"
local gui = New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	Name = "CountingGui",
	ZIndexBehavior = "Sibling",

	[Children] = {
		New "TextButton" {
			Name = "ClickButton",
			Position = UDim2.fromScale(.5, .5),
			Size = UDim2.fromOffset(200, 50),
			AnchorPoint = Vector2.new(.5, .5),

			BackgroundColor3 = Color3.fromRGB(85, 255, 0),

			Text = "Click me!"
		},

		New "TextLabel" {
			Name = "Message",
			Position = UDim2.new(0.5, 0, 0.5, 100),
			Size = UDim2.fromOffset(200, 50),
			AnchorPoint = Vector2.new(.5, .5),

			BackgroundColor3 = Color3.fromRGB(255, 255, 255),

			Text = "Placeholder message..."
		}
	}
}

```

With just these three instances, we have enough to work with for the rest of
this tutorial. Running the above script gives us this:

![Image of basic UI](BasicUI.png)