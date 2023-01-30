![Animation and graph showing basic spring response.](Step-Basic-Dark.png#only-dark)
![Animation and graph showing basic spring response.](Step-Basic-Light.png#only-light)

Springs follow the value of other state objects using a physical spring
simulation. This can be used for 'springy' effects, or for smoothing out
movement naturally without abrupt changes in direction.

-----

## Usage

To use `Spring` in your code, you first need to import it from the Fusion
module, so that you can refer to it by name:

```Lua linenums="1" hl_lines="2"
local Fusion = require(ReplicatedStorage.Fusion)
local Spring = Fusion.Spring
```

To create a new spring object, call the `Spring` function and pass it a state
object to move towards:

```Lua
local goal = Value(0)
local animated = Spring(target)
```

The spring will smoothly follow the 'goal' state object over time. As with other
state objects, you can `:get()` its value at any time:

```Lua
print(animated:get()) --> 0.26425...
```

To configure how the spring moves, you can provide a speed and damping ratio to
use. Both are optional, and both can be state objects if desired:

```Lua
local goal = Value(0)
local speed = 25
local damping = Value(0.5)
local animated = Spring(target, speed, damping)
```

You can use many different kinds of values with springs, not just numbers.
Vectors, CFrames, Color3s, UDim2s and other number-based types are supported;
each number inside the type is animated individually.

```Lua
local goalPosition = Value(UDim2.new(0.5, 0, 0, 0))
local animated = Spring(target, 25, 0.5)
```

-----

## Damping Ratio

The damping ratio (a.k.a damping) of the spring changes the friction in the
physics simulation. Lower values allow the spring to move freely and oscillate
up and down, while higher values restrict movement.

### Zero damping

![Animation and graph showing zero damping.](Damping-Zero-Dark.png#only-dark)
![Animation and graph showing zero damping.](Damping-Zero-Light.png#only-light)

Zero damping means no friction is applied, so the spring will oscillate forever
without losing energy. This is generally not useful.

### Underdamping

![Animation and graph showing underdamping.](Damping-Under-Dark.png#only-dark)
![Animation and graph showing underdamping.](Damping-Under-Light.png#only-light)

A damping between 0 and 1 means some friction is applied. The spring will still
oscillate, but it will lose energy and eventually settle at the goal.

### Critical damping

![Animation and graph showing critical damping.](Damping-Critical-Dark.png#only-dark)
![Animation and graph showing critical damping.](Damping-Critical-Light.png#only-light)

A damping of exactly 1 means just enough friction is applied to stop the spring
from oscillating. It reaches its goal as quickly as possible without going past.

This is also commonly known as critical damping.

### Overdamping

![Animation and graph showing overdamping.](Damping-Over-Dark.png#only-dark)
![Animation and graph showing overdamping.](Damping-Over-Light.png#only-light)

A damping above 1 applies excessive friction to the spring. The spring behaves
like it's moving through honey, glue or some other viscous fluid.

Overdamping reduces the effect of velocity changes, and makes movement more
rigid.

-----

## Speed

The speed of the spring scales how much time it takes for the spring to move.
Doubling the speed makes it move twice as fast; halving the speed makes it move
twice as slow.

![Animation and graph showing speed changes.](Speed-Dark.png#only-dark)
![Animation and graph showing speed changes.](Speed-Light.png#only-light)

-----

## Interruption

Springs do not share the same interruption problems as tweens. When the goal
changes, springs are guaranteed to preserve both position and velocity, reducing
jank:

![Animation and graph showing a spring getting interrupted.](Interrupted-Dark.png#only-dark)
![Animation and graph showing a spring getting interrupted.](Interrupted-Light.png#only-light)

This also means springs are suitable for following rapidly changing values:

![Animation and graph showing a spring following a moving target.](Following-Dark.png#only-dark)
![Animation and graph showing a spring following a moving target.](Following-Light.png#only-light)