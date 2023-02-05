<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">Animation</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-package-24:</span>
	<span class="fusiondoc-api-name">Tween</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">state object</span>
		<span class="fusiondoc-api-pill-since">since v0.1</span>
	</span>
</h1>

Follows the value of another state object, by tweening towards it.

If the state object is not [animatable](./animatable.md), the tween will
just snap to the goal value.

```Lua
(
	goal: StateObject<T>,
	tweenInfo: CanBeState<TweenInfo>?
) -> Tween<T>
```

-----

## Parameters

- `goal` - The state object whose value should be followed.
- `tweenInfo` - The style of tween to use when moving to the goal. Defaults
to `TweenInfo.new()`.

-----

## Example Usage

```Lua
local position = Value(UDim2.fromOffset(25, 50))
local smoothPosition = Tween(position, TweenInfo.new(2))

local ui = New "Frame" {
	Parent = PlayerGui.ScreenGui,
	Position = smoothPosition
}

while true do
	task.wait(5)
	position:set(peek(position) + UDim2.fromOffset(100, 100))
end
```