<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">Animation</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-package-24:</span>
	<span class="fusiondoc-api-name">Spring</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">state object</span>
		<span class="fusiondoc-api-pill-since">since v0.1</span>
	</span>
</h1>

Follows the value of another state object, as if linked by a damped spring.

If the state object is not [animatable](./animatable.md), the spring will
just snap to the goal value.

```Lua
(
	goal: StateObject<T>, 
	speed: CanBeState<number>?, 
	damping: CanBeState<number>?
) -> Spring<T>
```

-----

## Parameters

- `goal` - The state object whose value should be followed.
- `speed` - Scales the time it takes for the spring to move (but does not
directly correlate to a duration). Defaults to `10`.
- `damping` - Affects the friction/damping which the spring experiences. `0`
represents no friction, and `1` is just enough friction to reach the goal
without overshooting or oscillating. Defaults to `1`.

-----

## Methods

<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.1</span>
</p>

### :octicons-code-24: Spring:get()

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

<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

### :octicons-code-24: Spring:setPosition()

Instantaneously moves the spring to a new position. This does not affect the
velocity of the spring.

If the given value doesn't have the same type as the spring's current value,
the position will snap instantly to the new value.

```Lua
(newPosition: T) -> ()
```

#### Parameters

- `newPosition` - The value the spring's position should jump to.

-----

<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

### :octicons-code-24: Spring:setVelocity()

Overwrites the velocity of this spring. This does not have an immediate effect
on the position of the spring.

If the given value doesn't have the same type as the spring's current value,
the velocity will snap instantly to the new value.

```Lua
(newVelocity: T) -> ()
```

#### Parameters

- `newVelocity` - The value the spring's velocity should jump to.

-----

<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

### :octicons-code-24: Spring:addVelocity()

Adds to the velocity of this spring. This does not have an immediate effect
on the position of the spring.

If the given value doesn't have the same type as the spring's current value,
the velocity will snap instantly to the new value.

```Lua
(deltaVelocity: T) -> ()
```

#### Parameters

- `deltaVelocity` - The velocity to add to the spring.

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