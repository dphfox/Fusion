This example implements a procedural spinning animation using Fusion's Roblox
APIs.

-----

## Overview

```Lua linenums="1"
local RunService = game:GetService("RunService")

local Fusion = -- initialise Fusion here however you please!
local scoped = Fusion.scoped
local Children = Fusion.Children
type UsedAs<T> = Fusion.UsedAs<T>

local SPIN_DEGREES_PER_SECOND = 180
local SPIN_SIZE = 50

local function Spinner(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		Layout: {
			LayoutOrder: UsedAs<number>?,
			Position: UsedAs<UDim2>?,
			AnchorPoint: UsedAs<Vector2>?,
			ZIndex: UsedAs<number>?
		},
		CurrentTime: UsedAs<number>,
	}
): Fusion.Child
	return scope:New "ImageLabel" {
		Name = "Spinner",

		LayoutOrder = props.Layout.LayoutOrder,
		Position = props.Layout.Position,
		AnchorPoint = props.Layout.AnchorPoint,
		ZIndex = props.Layout.ZIndex,

		Size = UDim2.fromOffset(SPIN_SIZE, SPIN_SIZE),

		BackgroundTransparency = 1,
		Image = "rbxassetid://your-loading-spinner-image", -- replace this!

		Rotation = scope:Computed(function(use)
			return (use(props.CurrentTime) * SPIN_DEGREES_PER_SECOND) % 360
		end)
	}
end

-- Don't forget to pass this to `doCleanup` if you disable the script.
local scope = scoped(Fusion, {
	Spinner = Spinner
})

local currentTime = scope:Value(os.clock())
table.insert(scope,
	RunService.RenderStepped:Connect(function()
		currentTime:set(os.clock())
	end)
)

local spinner = scope:Spinner {
	Layout = {
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(50, 50)
	},
	CurrentTime = currentTime
}
```

-----

## Explanation

The `Spinner` components implements the animation for the loading spinner. It's
largely a standard Fusion component definition.

The main thing to note is that it asks for a `CurrentTime` property.

```Lua hl_lines="10"
local function Spinner(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		Layout: {
			LayoutOrder: UsedAs<number>?,
			Position: UsedAs<UDim2>?,
			AnchorPoint: UsedAs<Vector2>?,
			ZIndex: UsedAs<number>?
		},
		CurrentTime: UsedAs<number>,
	}
): Fusion.Child
```

The `CurrentTime` is used to drive the rotation of the loading spinner.

```Lua
		Rotation = scope:Computed(function(use)
			return (use(props.CurrentTime) * SPIN_DEGREES_PER_SECOND) % 360
		end)
```

That's all that's required for the `Spinner` component.

Later on, the example creates a `Value` object that will store the current time,
and starts a process to keep it up to date.

```Lua
local currentTime = scope:Value(os.clock())
table.insert(scope,
	RunService.RenderStepped:Connect(function()
		currentTime:set(os.clock())
	end)
)
```

This can then be passed in as `CurrentTime` when the `Spinner` is created.

```Lua hl_lines="7"
local spinner = scope:Spinner {
	Layout = {
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(50, 50)
	},
	CurrentTime = currentTime
}
```