```Lua linenums="1"
-- [Fusion imports omitted for clarity]

-- Oftentimes we calculate values for a single purpose, such as the position of
-- a single UI element. These values are often calculated inline, like this:

local menuBar = New "Frame" {
	AnchorPoint = Computed(function()
		return if menuIsOpen:get() then Vector2.new(0.5, 0) else Vector2.new(0.5, -1)
	end)
}

-- If you want to animate these inline values, you can pass them through an
-- object such as Spring and Tween- you don't have to do it separately.

local menuBar = New "Frame" {
	-- Use tweens for highly controllable animations:
	AnchorPoint = Tween(Computed(function()
		return if menuIsOpen:get() then Vector2.new(0.5, 0) else Vector2.new(0.5, -1)
	end), TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)),

	-- Or use springs for more natural and responsive movement:
	AnchorPoint = Spring(Computed(function()
		return if menuIsOpen:get() then Vector2.new(0.5, 0) else Vector2.new(0.5, -1)
	end), 20, 0.5)
}

-- The equivalent 'expanded' code looks like this:

local anchorPoint = Computed(function()
	return if menuIsOpen:get() then Vector2.new(0.5, 0) else Vector2.new(0.5, -1)
end)

local smoothAnchorPoint = Spring(anchorPoint, 20, 0.5) -- or equivalent Tween

local menuBar = New "Frame" {
	AnchorPoint = smoothAnchorPoint
}

-- Keep in mind that you probably shouldn't use inline animation for everything.
-- Sometimes you need to use the expanded form, or the expanded form would be
-- more efficient, and that's okay - choose what works best for your code :)
```