Now that we know how to represent and work with UI state, let's learn how to
link up our instances to our UI state so we can display a message on-screen.

??? abstract "Required code"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local Fusion = require(ReplicatedStorage.Fusion)

	local New = Fusion.New
	local Children = Fusion.Children

	local State = Fusion.State
	local Computed = Fusion.Computed

	local numPlayers = State(5)
	local message = Computed(function()
		return "There are " .. numPlayers:get() .. " online."
	end)

	local gui = New "ScreenGui" {
		Parent = Players.LocalPlayer.PlayerGui,

		Name = "ExampleGui",
		ResetOnSpawn = false,
		ZIndexBehavior = "Sibling",

		[Children] = New "TextLabel" {
			Position = UDim2.fromScale(.5, .5),
			AnchorPoint = Vector2.new(.5, .5),
			Size = UDim2.fromOffset(200, 50)
		}
	}
	```

-----

## Using State For Properties

So far, we've seen how the `New` function can set properties on an instance.
From the code above:

```Lua linenums="16"
local gui = New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	Name = "ExampleGui",
	ResetOnSpawn = false,
	ZIndexBehavior = "Sibling",

	[Children] = New "TextLabel" {
		Position = UDim2.fromScale(.5, .5),
		AnchorPoint = Vector2.new(.5, .5),
		Size = UDim2.fromOffset(200, 50)
	}
}
```

-----

## Deferred Updates



-----

Summary text

??? summary "Finished code"
	```Lua linenums="1"
	```