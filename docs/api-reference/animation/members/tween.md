<nav class="fusiondoc-api-breadcrumbs">
	<span>Animation</span>
	<span>Members</span>
	<span>Tween</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">Tween</span>
	<span class="fusiondoc-api-type">
		-> <a href="../../types/tween">Tween</a>&lt;T&gt;
	</span>
</h1>

```Lua
function Fusion.Tween<T>(
	scope: Scope<unknown>,
	goal: UsedAs<T>,
	tweenInfo: UsedAs<TweenInfo>?
) -> Tween<T>
```

Constructs and returns a new [tween state object](../../types/tween).

!!! success "Use scoped() method syntax"
	This function is intended to be accessed as a method on a scope:
	```Lua
	local tween = scope:Tween(goal, info)
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
		: <a href="../../../state/types/usedas">UsedAs</a>&lt;T&gt;
	</span>
</h3>

The goal that this object should follow. For best results, the goal should be
[animatable](../../types/animatable).

<h3 markdown>
	info
	<span class="fusiondoc-api-type">
		: <a href="../../../state/types/usedas">UsedAs</a>&lt;TweenInfo&gt;?
	</span>
</h3>

Determines the easing curve that the motion will follow.

-----

<h2 markdown>
	Returns
	<span class="fusiondoc-api-type">
		-> <a href="../../types/tween">Tween</a>&lt;T&gt;
	</span>
</h2>

A freshly constructed tween state object.

-----

## Learn More

- [Tweens tutorial](../../../../tutorials/animation/tweens)