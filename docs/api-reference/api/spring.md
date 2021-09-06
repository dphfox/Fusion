```Lua
function Spring(goalValue: State<Animatable>, speed: number?, dampingRatio: number?): Spring
```

Constructs and returns a new Spring state object, which follows the value of
`goalValue`. The value of this object is simulated physically, as if linked to
the goal value by a damped spring.

`speed` acts like a time multiplier; doubling `speed` corresponds to movement
which is twice as fast.

`dampingRatio` affects the friction; `0` represents no friction, and `1` is
just enough friction to reach the goal without overshooting or oscillating. This
can be varied freely to fine-tune how much friction or 'bounce' your motion has.

-----

## Parameters

- `goalValue: State<Animatable>` - the goal value this object should approach
- `speed: number?` - how fast this object should approach the goal
- `dampingRatio: number?` - scales how much friction is applied

-----

## Object Methods

### `get()`

```Lua
function Spring:get(): any
```
Returns the currently stored value of this Spring state object.

If dependencies are currently being detected (e.g. inside a computed callback),
then this state object will be used as a dependency.

-----

## Example Usage

```Lua
local position = State(UDim2.fromScale(0.25, 0.25))

local ui = New "Frame" {
	Position = Spring(position, 25, 0.5)
}
```

```Lua
local playerCount = State(0)
local smoothPlayerCount = Spring(playerCount)

local message = Computed(function()
	return "Currently online: " .. math.floor(smoothPlayerCount:get())
end)
```