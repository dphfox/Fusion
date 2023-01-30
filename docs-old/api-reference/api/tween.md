```Lua
function Tween(goalValue: State<Animatable>, tweenInfo: TweenInfo?): Tween
```

Constructs and returns a new Tween state object, which follows the value of
`goalValue`. When the goal value changes, the value of this object is tweened
towards the goal value using the given `tweenInfo`.

-----

## Parameters

- `goalValue: State<Animatable>` - the goal value this object should approach
- `tweenInfo: TweenInfo?` - the tween to use when animating this object's value

-----

## Object Methods

### `get()`

```Lua
function Tween:get(): any
```
Returns the currently stored value of this Tween state object.

If dependencies are currently being detected (e.g. inside a computed callback),
then this state object will be used as a dependency.

-----

## Example Usage

```Lua
local EASE = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local position = State(UDim2.fromScale(0.25, 0.25))
local ui = New "Frame" {
	Position = Tween(position, EASE)
}
```

```Lua
local playerCount = State(0)
local smoothPlayerCount = Tween(playerCount)

local message = Computed(function()
	return "Currently online: " .. math.floor(smoothPlayerCount:get())
end)
```