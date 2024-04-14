![Animation and graph showing basic tween response.](Step-Basic-Dark.png#only-dark)
![Animation and graph showing basic tween response.](Step-Basic-Light.png#only-light)

Tweens follow the value of other state objects using a pre-made animation curve.
This can be used for basic, predictable animations.

-----

## Usage

To create a new tween object, call `scope:Tween()` and pass it a state object to
move towards:

```Lua
local goal = scope:Value(0)
local animated = scope:Tween(goal)
```

The tween will smoothly follow the 'goal' state object over time.

As with other state objects, you can `peek()` at its value at any time:

```Lua
print(peek(animated)) --> 0.26425...
```

To configure how the tween moves, you can provide a TweenInfo to change the
shape of the animation curve. It's optional, and it can be a state object if
desired:

```Lua
local goal = scope:Value(0)
local style = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
local animated = scope:Tween(goal, style)
```

You can use many different kinds of values with tweens, not just numbers.
Vectors, CFrames, Color3s, UDim2s and other number-based types are supported;
each number inside the type is animated individually.

```Lua
local goalPosition = scope:Value(UDim2.new(0.5, 0, 0, 0))
local animated = scope:Tween(goalPosition, TweenInfo.new(0.5, Enum.EasingStyle.Quad))
```

-----

## Time

The first parameter of `TweenInfo` is time. This specifies how long it should
take for the value to animate to the goal, in seconds.

![Animation and graph showing varying TweenInfo time.](Time-Dark.png#only-dark)
![Animation and graph showing varying TweenInfo time.](Time-Light.png#only-light)

-----

## Easing Style

The second parameter of `TweenInfo` is easing style. By setting this to various
`Enum.EasingStyle` values, you can select different pre-made animation curves.

![Animation and graph showing some easing styles.](Easing-Style-Dark.png#only-dark)
![Animation and graph showing some easing styles.](Easing-Style-Light.png#only-light)

-----

## Easing Direction

The third parameter of `TweenInfo` is easing direction. This can be set to one
of three values to control how the tween starts and stops:

- `Enum.EasingDirection.Out` makes the tween animate out smoothly.
- `Enum.EasingDirection.In` makes the tween animate in smoothly.
- `Enum.EasingDirection.InOut` makes the tween animate in *and* out smoothly.

![Animation and graph showing some easing directions.](Easing-Direction-Dark.png#only-dark)
![Animation and graph showing some easing directions.](Easing-Direction-Light.png#only-light)

-----

## Repeats

The fourth parameter of `TweenInfo` is repeat count. This can be used to loop
the animation a number of times.

Setting the repeat count to a negative number causes it to loop infinitely. This
is not generally useful for transition animations.

![Animation and graph showing various repeat counts.](Repeats-Dark.png#only-dark)
![Animation and graph showing various repeat counts.](Repeats-Light.png#only-light)

-----

## Reversing

The fifth parameter of `TweenInfo` is a reversing option. When enabled, the
animation will return to the starting point.

This is not typically useful because the animation doesn't end at the goal value,
and might not end at the start value either if the animation is interrupted.

![Animation and graph toggling reversing on and off.](Reversing-Dark.png#only-dark)
![Animation and graph toggling reversing on and off.](Reversing-Light.png#only-light)

-----

## Delay

The sixth and final parameter of `TweenInfo` is delay. Increasing this delay
adds empty space before the beginning of the animation curve.

It's important to note this is *not* the same as a true delay. This option does
not delay the input signal - it only makes the tween animation longer.

![Animation and graph showing varying delay values.](Delay-Dark.png#only-dark)
![Animation and graph showing varying delay values.](Delay-Light.png#only-light)

-----

## Interruption

Because tweens are built from pre-made, fixed animation curves, you should avoid
interrupting those animation curves before they're finished.

Interrupting a tween halfway through leads to abrupt changes in velocity, which
can cause your animation to feel janky:

![Animation and graph showing a tween getting interrupted.](Interrupted-Dark.png#only-dark)
![Animation and graph showing a tween getting interrupted.](Interrupted-Light.png#only-light)

Tweens also can't track constantly changing targets very well. That's because
the tween is always getting interrupted as it gets started, so it never has time
to play out much of its animation.

![Animation and graph showing a tween failing to follow a moving target.](Follow-Failure-Dark.png#only-dark)
![Animation and graph showing a tween failing to follow a moving target.](Follow-Failure-Light.png#only-light)

These issues arise because tweens don't 'remember' their previous velocity when
they start animating towards a new goal. If you need velocity to be remembered,
it's a much better idea to use springs, which can preserve their momentum.