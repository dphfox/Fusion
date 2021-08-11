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

In our current code, we're using state and computed objects to store and process
some data:

```Lua linenums="11"
local numPlayers = State(5)
local message = Computed(function()
	return "There are " .. numPlayers:get() .. " online."
end)
```

When we use the `New` function, we can use these state objects as properties.
In other words, we can set the Text of our label to be our `message` state:

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

This will set the Text to whatever's stored in `message`, and keeps it updated
as `message` is changed.

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

It's worth noting that property changes aren't applied right away - they're
deferred until the next render step.

In this example, the value of the state object is changed many times. However,
Fusion will only update the property at the next render step, meaning we only
see the last change have an effect:

=== "Lua"
	```Lua
	local state = State(1)

	local ins = New "NumberValue" {
		Value = state,
		[OnChange "Value"] = function(newValue)
			print("Value is now:", newValue)
		end)
	}

	state:set(2)
	state:set(3)
	state:set(4)
	state:set(5)
	```
=== "Expected output"
	```
	Value is now: 5
	```

This is done for optimisation purposes; while it's relatively cheap to update
state objects many times per frame, it's expensive to update instances.
Furthermore, there's no reason to update an instance many times per frame, since
it'll only be rendered once.

In almost all cases, this is a desirable optimisation. However, in a select few
cases, it can be problematic.

Specifically, in the above example, the `OnChange` handler is not fired every
time the state object changes value. Instead, it's fired in the render step
*after* the state object is changed, because that's when the property actually
changes.

This can lead to subtle off-by-one-frame errors if you're not careful, so be
cautious about using `OnChange` on properties you also bind state to.

-----

That's everything you need to know about connecting properties with state - it's
a simple concept, but fundamental to creating dynamic and interactive UIs.

??? summary "Finished code"
	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local Fusion = require(ReplicatedStorage.Fusion)

	local New = Fusion.New
	local Children = Fusion.Children

	local State = Fusion.State
	local Computed = Fusion.Computed

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