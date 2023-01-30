```Lua linenums="1"
local RunService = game:GetService("RunService")
-- [Fusion imports omitted for clarity]

-- Loading spinners generally don't use transition-based animations like tweens.
-- Instead, they animate continuously and independently, so we'll need to set up
-- our own animation clock that will drive the animation.
-- We can set up one clock and use it everywhere.
local timer = Value(os.clock())
local timerConn = RunService.RenderStepped:Connect(function()
	-- Remember to disconnect this event when you're done using it!
	timer:set(os.clock())
end)

-- Our loading spinner will consist of an image which rotates around. You could
-- do something more complex or intricate for spice, but in the interest of
-- providing a simple starting point, let's keep it simple.
local spinner = New "ImageLabel" {
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromOffset(50, 50),

	BackgroundTransparency = 1,
	Image = "rbxassetid://your-loading-spinner-image", -- replace this!

	-- As the timer runs, this will automatically update and rotate our image.
	Rotation = Computed(function()
		local time = timer:get()
		local angle = time * 180 -- Spin at a rate of 180 degrees per second
		angle %= 360 -- Don't need to go beyond 360 degrees; wrap instead
		return angle
	end),

	-- If your `timer` is only used by this one loading spinner, you can clean
	-- up the `timerConn` here. If you're re-using one timer for all of your
	-- spinners, you don't need to do this here.
	[Cleanup] = timerConn
}
```