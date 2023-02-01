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

## Methods

<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.1</span>
</p>

### :octicons-code-24: Tween:get()

Returns the current value stored in the state object.

If dependencies are being captured (e.g. inside a computed callback), this state
object will also be added as a dependency.

```Lua
(asDependency: boolean?) -> T
```

#### Parameters

- `asDependency` - If this is explicitly set to false, no dependencies will be
captured.

-----

## Example Usage

```Lua
local position = Value(UDim2.fromOffset(25, 50))
local smoothPosition = Spring(position, 25, 0.6)

local ui = New "Frame" {
	Parent = PlayerGui.ScreenGui,
	Position = smoothPosition
}

while true do
	task.wait(5)
	-- apply an impulse
	smoothPosition:addVelocity(UDim2.fromOffset(-10, 10))
end
```