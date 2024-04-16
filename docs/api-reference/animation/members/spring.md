<nav class="fusiondoc-api-breadcrumbs">
	<span>Animation</span>
	<span>Members</span>
	<span>Spring</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">Spring</span>
	<span class="fusiondoc-api-type">
		-> <a href="../../types/spring">Spring</a>&lt;T&gt;
	</span>
</h1>

```Lua
function Fusion.Spring<T>(
	scope: Scope<unknown>,
	goal: UsedAs<T>,
	speed: UsedAs<number>?,
	damping: UsedAs<number>?
) -> Spring<T>
```

Constructs and returns a new [spring state object](../../types/spring).

!!! success "Use scoped() method syntax"
	This function is intended to be accessed as a method on a scope:
	```Lua
	local spring = scope:Spring(goal, speed, damping)
	```

-----

## Parameters

<h3 markdown>
	scope
	<span class="fusiondoc-api-type">
		: <a href="../../../memory/types/scope">Scope</a>&lt;S&gt;
	</span>
</h3>

The [scope](../../../memory/types/scope) which should be used to store
destruction tasks for this object.

<h3 markdown>
	goal
	<span class="fusiondoc-api-type">
		: <a href="../../../state/types/used">UsedAs</a>&lt;T&gt;
	</span>
</h3>

The goal that this object should follow. For best results, the goal should be
[animatable](../../types/animatable).

<h3 markdown>
	speed
	<span class="fusiondoc-api-type">
		: <a href="../../../state/types/usedas">UsedAs</a>&lt;T&gt;?
	</span>
</h3>

Multiplies how fast the motion should occur; doubling the `speed` exactly halves
the time it takes for the motion to complete.

<h3 markdown>
	damping
	<span class="fusiondoc-api-type">
		: <a href="../../../state/types/usedas">UsedAs</a>&lt;T&gt;?
	</span>
</h3>

The amount of resistance the motion encounters. 0 represents no resistance,
1 is just enough resistance to prevent overshoot (critical damping), and larger
values damp out inertia effects and straighten the motion.

-----

<h2 markdown>
	Returns
	<span class="fusiondoc-api-type">
		-> <a href="../../types/spring">Spring</a>&lt;T&gt;
	</span>
</h2>

A freshly constructed spring state object.

-----

## Learn More

- [Springs tutorial](../../../../tutorials/animation/springs)