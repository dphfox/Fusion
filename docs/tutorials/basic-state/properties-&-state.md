Now that we know how to represent and work with UI state, let's learn how to
link up properties to our UI state so we can display a message on-screen.

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

## Passing State To Properties

Up until now, we've dealt with UI and state management as two separate systems.
However, the `New` function allows us to connect the two easily; this is one of
the things building UI from code makes simpler.

We already know that the `New` function can be used to set properties - in the
code above, we're already using this to build a simple UI:

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

Above that, we're using state and computed objects to store and process some
simple data:

```Lua linenums="11"
local numPlayers = State(5)
local message = Computed(function()
	return "There are " .. numPlayers:get() .. " online."
end)
```

The `New` function accepts these objects as properties directly. In other words,
we can intuitively set the Text of our label to be `message`:

```Lua linenums="11" hl_lines="18"
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
		Size = UDim2.fromOffset(200, 50),

		Text = message
	}
}
```

The above code *binds* our UI state to a property; that is, it sets the Text to
the value of `message`, and updates the Text whenever `message` changes.

To keep things neat and tidy, you can create the computed object directly next
to the property instead, to keep it close to where it's used:

```Lua linenums="11" hl_lines="15-17"
local numPlayers = State(5)

local gui = New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	Name = "ExampleGui",
	ResetOnSpawn = false,
	ZIndexBehavior = "Sibling",

	[Children] = New "TextLabel" {
		Position = UDim2.fromScale(.5, .5),
		AnchorPoint = Vector2.new(.5, .5),
		Size = UDim2.fromOffset(200, 50),

		Text = Computed(function()
			return "There are " .. numPlayers:get() .. " online."
		end)
	}
}
```

That's all you need to know - it's trivial to use any state as a property when
using the `New` function.

-----

## Deferred Updates

It's worth noting that property changes aren't applied right away.

-----

Summary text

??? summary "Finished code"
	```Lua linenums="1"
	```