This example shows you how to animate a single value with an animation curve of
your preference.

For demonstration, the example uses Roblox API members.

-----

## Overview

```Lua linenums="1"
local Players = game:GetService("Players")

local Fusion = -- initialise Fusion here however you please!
local scoped = Fusion.scoped
local Children = Fusion.Children

local TWEEN_INFO = TweenInfo.new(
	0.5,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.InOut
)

-- Don't forget to pass this to `doCleanup` if you disable the script.
local scope = scoped(Fusion)

-- You can set this at any time to indicate where The Thing should be.
local showTheThing = scope:Value(false)

local exampleUI = scope:New "ScreenGui" {
	Parent = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui"),
	Name = "Example UI",

	[Children] = scope:New "Frame" {
		Name = "The Thing",
		Position = scope:Tween(
			scope:Computed(function(use)
				local CENTRE = UDim2.fromScale(0.5, 0.5)
				local OFFSCREEN = UDim2.fromScale(-0.5, 0.5)
				return if use(showTheThing) then CENTRE else OFFSCREEN
			end),
			TWEEN_INFO
		),
		Size = UDim2.fromOffset(200, 200)
	}
}

-- Without toggling the value, you won't see it animate.
task.defer(function()
	while true do
		task.wait(1)
		showTheThing:set(not peek(showTheThing))
	end
end)
```

-----

## Explanation

There's three key components to the above code snippet.

Firstly, there's `showTheThing`. When this is `true`, The Thing should be in
the centre of the screen. Otherwise, The Thing should be off-screen.

```Lua
-- You can set this at any time to indicate where The Thing should be.
local showTheThing = scope:Value(false)
```

Next, there's the computed object on line 26. This takes that boolean value, and
turns it into a UDim2 position for The Thing to use. You can imagine this as the
'non-animated' version of what you want The Thing to do, if it were to instantly
teleport around.

```Lua
			scope:Computed(function(use)
				local CENTRE = UDim2.fromScale(0.5, 0.5)
				local OFFSCREEN = UDim2.fromScale(-0.5, 0.5)
				return if use(showTheThing) then CENTRE else OFFSCREEN
			end),
```

Finally, there's the tween object that the computed is being passed into. The
tween object will smoothly move towards the computed over time. If needed, you
could separate the computed into a dedicated variable to access it
independently.

```Lua
		Position = scope:Tween(
			scope:Computed(function(use)
				local CENTRE = UDim2.fromScale(0.5, 0.5)
				local OFFSCREEN = UDim2.fromScale(-0.5, 0.5)
				return if use(showTheThing) then CENTRE else OFFSCREEN
			end),
			TWEEN_INFO
		),
```

The 'shape' of the animation is saved in a `TWEEN_INFO` constant defined earlier
in the code. [The Tween tutorial](../../../tutorials/animation/tweens) explains
how each parameter shapes the motion.

```Lua
local TWEEN_INFO = TweenInfo.new(
    0.5,
    Enum.EasingStyle.Sine,
    Enum.EasingDirection.InOut
)
```

!!! tip "Fluid animations with springs"
	For extra smooth animation shapes that preserve velocity, consider trying
	[spring objects](../../../tutorials/animation/springs). They're very similar
	in usage and can help improve the responsiveness of the motion.