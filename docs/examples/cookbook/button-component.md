```Lua linenums="1"
-- [Fusion imports omitted for clarity]

-- This is a relatively complete example of a button component.
-- It handles many common interactions such as hovering and clicking.

-- This should be a generally useful template for assembling components of your
-- own. Unless you're prototyping, it's probably wise to stick to some good
-- guidelines; the Tutorials have some tips if you don't have any existing
-- guidelines of your own.

-- Defining the names of properties the button accepts, and their types. This is
-- useful for autocomplete and helps catch some typos, but is optional.
export type Props = {
	-- some generic properties we'll allow other code to control directly
	Name: CanBeState<string>?,
	LayoutOrder: CanBeState<number>?,
	Position: CanBeState<UDim2>?,
	AnchorPoint: CanBeState<Vector2>?,
	Size: CanBeState<UDim2>?,
	AutomaticSize: CanBeState<Enum.AutomaticSize>?,
	ZIndex: CanBeState<number>?,

	-- button-specific properties
	Text: CanBeState<string>?,
	OnClick: (() -> ())?,
	Disabled: CanBeState<boolean>?
}

-- Returns `Child` to match Fusion's `Component` type. This should work for most
-- use cases, and offers the greatest encapsulation as you're able to swap out
-- your return type for an array or state object if you want to.
local function Button(props: Props): Child
	-- To simplify our code later (because we're going to operate on this value)
	if props.Disabled == nil then
		props.Disabled = Value(false)
	elseif typeof(props.Disabled) == "boolean" then
		props.Disabled = Value(props.Disabled)
	end

	-- We should generally be careful about storing state in widely reused
	-- components, as the Tutorials explain, but for contained use cases such as
	-- hover states, it should be perfectly fine.
	local isHovering = Value(false)
	local isHeldDown = Value(false)

	return New "TextButton" {
		Name = props.Name,
		LayoutOrder = props.LayoutOrder,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		AutomaticSize = props.AutomaticSize,
		ZIndex = props.ZIndex,

		Text = props.Text,
		TextColor3 = Color3.fromHex("FFFFFF"),

		BackgroundColor3 = Spring(Computed(function()
			if props.Disabled:get() then
				return Color3.fromHex("CCCCCC")
			else
				local baseColour = Color3.fromHex("0085FF")
				-- darken/lighten when hovered or held down
				if isHeldDown:get() then
					baseColour = baseColour:Lerp(Color3.new(0, 0, 0), 0.25)
				elseif isHovering:get() then
					baseColour = baseColour:Lerp(Color3.new(1, 1, 1), 0.25)
				end
				return baseColour
			end
		end), 20),

		[OnEvent "Activated"] = function()
			-- Because we're not in a Computed callback (or similar), it's a
			-- good idea to :get(false) so we're not adding any dependencies
			-- anywhere.
			if props.OnClick ~= nil and not props.Disabled:get(false) then
				-- We're explicitly calling this function with no arguments to
				-- match the types we specified above. If we just passed it
				-- straight into the event, the function would receive arguments
				-- from the Activated event, which might not be desirable.
				props.OnClick()
			end
		end,

		[OnEvent "MouseButton1Down"] = function()
			isHeldDown:set(true) -- it's good UX to give immediate feedback
		end,

		[OnEvent "MouseButton1Up"] = function()
			isHeldDown:set(false)
		end,

		[OnEvent "MouseEnter"] = function()
			-- Roblox calls this event even if the button is being covered by
			-- other UI. For simplicity, we won't worry about that.
			isHovering:set(true)
		end,

		[OnEvent "MouseLeave"] = function()
			isHovering:set(false)
			-- If the button is being held down, but the cursor moves off the
			-- button, then we won't receive the mouse up event. To make sure
			-- the button doesn't get stuck held down, we'll release it if the
			-- cursor leaves the button.
			isHeldDown:set(false)
		end,

		[Children] = {
			New "UICorner" {
				CornerRadius = UDim.new(0, 4)
			},

			New "UIPadding" {
				PaddingTop = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 6),
				PaddingLeft = UDim.new(0, 6),
				PaddingRight = UDim.new(0, 6)
			}
		}
	}
end

return Button
```