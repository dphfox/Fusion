<nav class="fusiondoc-api-breadcrumbs">
	<span>State</span>
	<span>Types</span>
	<span>Computed</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">Computed</span>
</h1>

```Lua
export type Computed<T> = StateObject<T> & Dependent & {
	kind: "Computed"
}
```

A specialised [state object](../stateobject) for tracking single values computed
from a user-defined computation.

In addition to the standard state object interfaces, this object is a 
[dependent](../dependent) so it can receive updates from the objects used as
part of the computation.

This type isn't generally useful outside of Fusion itself.

-----

## Members

<h3 markdown>
	kind
	<span class="fusiondoc-api-type">
		: "Computed"
	</span>
</h3>

A more specific type string which can be used for runtime type checking. This
can be used to tell types of state object apart.

-----

## Learn More

- [Computeds tutorial](../../../../tutorials/fundamentals/computeds)