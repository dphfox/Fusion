<nav class="fusiondoc-api-breadcrumbs">
	<span>State</span>
	<span>Types</span>
	<span>StateObject</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">StateObject</span>
</h1>

```Lua
export type StateObject<T> = Dependency & {
	type: "State",
	kind: string
}
```

Stores a value of `T` which can change over time. As a
[dependency](../dependency), it can broadcast updates when its value changes.

This type isn't generally useful outside of Fusion itself; you should prefer to
work with [`UsedAs<T>`](../usedas) in your own code.

-----

## Members

<h3 markdown>
	type
	<span class="fusiondoc-api-type">
		: "State"
	</span>
</h3>

A type string which can be used for runtime type checking.

<h3 markdown>
	kind
	<span class="fusiondoc-api-type">
		: string
	</span>
</h3>

A more specific type string which can be used for runtime type checking. This
can be used to tell types of state object apart.