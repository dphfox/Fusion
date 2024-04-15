<nav class="fusiondoc-api-breadcrumbs">
	<span>Animation</span>
	<span>Types</span>
	<span>Tween</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">Tween</span>
</h1>

```Lua
export type Tween<T> = StateObject<T> & Dependent & {
	kind: "Tween"
}
```

A specialised [state object](../stateobject) for following a goal state smoothly
over time, using a `TweenInfo` to shape the motion.

In addition to the standard state object interfaces, this object is a 
[dependent](../dependent) so it can receive updates from the goal state.

This type isn't generally useful outside of Fusion itself.

-----

## Members

<h3 markdown>
	kind
	<span class="fusiondoc-api-type">
		: "Tween"
	</span>
</h3>

A more specific type string which can be used for runtime type checking. This
can be used to tell types of state object apart.

-----

## Learn More

- [Tweens tutorial](../../../../tutorials/animation/tweens)