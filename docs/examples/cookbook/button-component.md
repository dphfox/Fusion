This example is a relatively complete button component implemented using
Fusion's Roblox API. It handles many common interactions such as hovering and
clicking.

This should be a generally useful template for assembling components of your
own. For further ideas and best practices for building components, see
[the Components tutorial](../../../tutorials/components/components).


-----

## Overview

```Lua linenums="1"
local Fusion = -- initialise Fusion here however you please!
local scoped = Fusion.scoped
local Children, OnEvent = Fusion.Children, Fusion.OnEvent
type UsedAs<T> = Fusion.UsedAs<T>

local COLOUR_BLACK = Color3.new(0, 0, 0)
local COLOUR_WHITE = Color3.new(1, 1, 1)

local COLOUR_TEXT = COLOUR_WHITE
local COLOUR_BG_REST = Color3.fromHex("0085FF")
local COLOUR_BG_HOVER = COLOUR_BG_REST:Lerp(COLOUR_WHITE, 0.25)
local COLOUR_BG_HELD = COLOUR_BG_REST:Lerp(COLOUR_BLACK, 0.25)
local COLOUR_BG_DISABLED = Color3.fromHex("CCCCCC")

local BG_FADE_SPEED = 20 -- spring speed units

local ROUNDED_CORNERS = UDim.new(0, 4)
local PADDING = UDim2.fromOffset(6, 4)

local function Button(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		Name: UsedAs<string>?,
		Layout: {
			LayoutOrder: UsedAs<number>?,
			Position: UsedAs<UDim2>?,
			AnchorPoint: UsedAs<Vector2>?,
			ZIndex: UsedAs<number>?,
			Size: UsedAs<UDim2>?,
			AutomaticSize: UsedAs<Enum.AutomaticSize>?
		},
		Text: UsedAs<string>?,
		Disabled: UsedAs<boolean>?,
		OnClick: (() -> ())?
	}
): Fusion.Child
	local isHovering = scope:Value(false)
	local isHeldDown = scope:Value(false)

	return scope:New "TextButton" {
		Name = props.Name,

		LayoutOrder = props.Layout.LayoutOrder,
		Position = props.Layout.Position,
		AnchorPoint = props.Layout.AnchorPoint,
		ZIndex = props.Layout.ZIndex,
		Size = props.Layout.Size,
		AutomaticSize = props.Layout.AutomaticSize,

		Text = props.Text,
		TextColor3 = COLOUR_TEXT,

		BackgroundColor3 = scope:Spring(
			scope:Computed(function(use)
				-- The order of conditions matter here; it defines which states
				-- visually override other states, with earlier states being
				-- more important.
				return
					if use(props.Disabled) then COLOUR_BG_DISABLED
					elseif use(isHeldDown) then COLOUR_BG_HELD
					elseif use(isHovering) then COLOUR_BG_HOVER
					else return COLOUR_BG_REST
				end
			end), 
			BG_FADE_SPEED
		),

		[OnEvent "Activated"] = function()
			if props.OnClick ~= nil and not peek(props.Disabled) then
				-- Explicitly called with no arguments to match the typedef. 
				-- If passed straight to `OnEvent`, the function might receive
				-- arguments from the event. If the function secretly *does*
				-- take arguments (despite the type) this would cause problems.
				props.OnClick()
			end
		end,

		[OnEvent "MouseButton1Down"] = function()
			isHeldDown:set(true)
		end,
		[OnEvent "MouseButton1Up"] = function()
			isHeldDown:set(false)
		end,

		[OnEvent "MouseEnter"] = function()
			-- Roblox calls this event even if the button is being covered by
			-- other UI. For simplicity, this does not account for that.
			isHovering:set(true)
		end,
		[OnEvent "MouseLeave"] = function()
			-- If the button is being held down, but the cursor moves off the
			-- button, then we won't receive the mouse up event. To make sure
			-- the button doesn't get stuck held down, we'll release it if the
			-- cursor leaves the button.
			isHeldDown:set(false)
			isHovering:set(false)
		end,

		[Children] = {
			New "UICorner" {
				CornerRadius = ROUNDED_CORNERS
			},

			New "UIPadding" {
				PaddingTop = PADDING.Y,
				PaddingBottom = PADDING.Y,
				PaddingLeft = PADDING.X,
				PaddingRight = PADDING.X
			}
		}
	}
end

return Button
```

-----

## Explanation

The main part of note is the function signature. It's highly recommended that
you statically type the function signature for components, because it not only
improves autocomplete and error checking, but also acts as up-to-date, machine
readable documentation.

```Lua
local function Button(
	scope: Fusion.Scope<typeof(Fusion)>,
	props: {
		Name: UsedAs<string>?,
		Layout: {
			LayoutOrder: UsedAs<number>?,
			Position: UsedAs<UDim2>?,
			AnchorPoint: UsedAs<Vector2>?,
			ZIndex: UsedAs<number>?,
			Size: UsedAs<UDim2>?,
			AutomaticSize: UsedAs<Enum.AutomaticSize>?
		},
		Text: UsedAs<string>?,
		Disabled: UsedAs<boolean>?,
		OnClick: (() -> ())?
	}
): Fusion.Child
```

The `scope` parameter specifies that the component depends on Fusion's methods.
If you're not sure how to write type definitions for scopes,
[the 'Scopes' section of the Components tutorial](../../../tutorials/components/components/#scopes)
goes into further detail.

The property table is laid out with each property on a new line, so it's easy to
scan the list and see what properties are available. Most are typed with
[`UsedAs`](../../../api-reference/state/types/usedas), which allows the user to 
use state objects if they desire. They're also `?` (optional), which can reduce
boilerplate when using the component. Not all properties have to be that way,
but usually it's better to have the flexibility.

!!! tip "Property grouping"
	You can group properties together in nested tables, like the `Layout` table
	above, to avoid long mixed lists of properties. In addition to being more
	readable, this can sometimes help with passing around lots of properties at
	once, because you can pass the whole nested table as one value if you'd like
	to.

The return type of the function is `Fusion.Child`, which tells the user that the
component is compatible with Fusion's `[Children]` API, without exposing what
children it's returning specifically. This helps ensure the user doesn't
accidentally depend on the internal structure of the component.