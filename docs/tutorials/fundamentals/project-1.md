!!! warning "Under construction"
	This page is under construction - information may be incomplete or missing.

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

-----

## Adding State

Now, let's add some state to make our UI dynamic. Let's start with a state
object to store the number of clicks:

```Lua linenums="12" hl_lines="1"
local numClicks = State(0)

local gui = New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	Name = "CountingGui",
	ZIndexBehavior = "Sibling",

	[Children] = {

```

Now, we can replace the placeholder text with some computed state, to turn our
number of clicks into a fully-formed message:

```Lua linenums="29" hl_lines="12-14"
			Text = "Click me!"
		},

		New "TextLabel" {
			Name = "Message",
			Position = UDim2.new(0.5, 0, 0.5, 100),
			Size = UDim2.fromOffset(200, 50),
			AnchorPoint = Vector2.new(.5, .5),

			BackgroundColor3 = Color3.fromRGB(255, 255, 255),

			Text = Computed(function()
				return "You clicked " .. numClicks:get() .. " times."
			end)
		}
	}
}
```

You'll now notice the message's text reflects the number of clicks stored in
`numClicks`:

![Image of UI with message using computed state](UIWithState.png)

-----

## Listening for Clicks

Now that we have our UI in place and it's working with our state, we just need
to increment the number stored in `numClicks` when we click the button.

To start, let's add an `OnEvent` handler for the button's Activated event. This
will run when we click the button:

```Lua hl_lines="12-15"
	[Children] = {
		New "TextButton" {
			Name = "ClickButton",
			Position = UDim2.fromScale(.5, .5),
			Size = UDim2.fromOffset(200, 50),
			AnchorPoint = Vector2.new(.5, .5),

			BackgroundColor3 = Color3.fromRGB(85, 255, 0),

			Text = "Click me!",

			[OnEvent "Activated"] = function()
				-- the button was clicked!
				-- TODO: increment state
			end
		},

		New "TextLabel" {
```

Then, to increment the state, we can `:get()` the number of clicks, add one,
then `:set()` it to the new value:

```Lua hl_lines="14"
	[Children] = {
		New "TextButton" {
			Name = "ClickButton",
			Position = UDim2.fromScale(.5, .5),
			Size = UDim2.fromOffset(200, 50),
			AnchorPoint = Vector2.new(.5, .5),

			BackgroundColor3 = Color3.fromRGB(85, 255, 0),

			Text = "Click me!",

			[OnEvent "Activated"] = function()
				-- the button was clicked!
				numClicks:set(numClicks:get() + 1)
			end
		},

		New "TextLabel" {
```

That's everything - try clicking the button, and watch the message change in
response:

![Image of finished UI responding to clicks](FinishedUI.png)

-----

If you've managed to follow along, congratulations - you should now have a good
understanding of Fusion's fundamental concepts!

With just these tools alone, you'll be able to build almost anything you can
think of. However, Fusion still has more tools available to make your code
simpler and easier to manage - we'll cover this in *'Further Basics'*.