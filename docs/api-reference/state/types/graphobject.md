<nav class="fusiondoc-api-breadcrumbs">
	<span>State</span>
	<span>Types</span>
	<span>GraphObject</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">GraphObject</span>
</h1>

```Lua
export type GraphObject = ScopedObject & {
	dependencySet: {[GraphObject]: unknown},
	dependentSet: {[GraphObject]: unknown},
	invalidation: "none" | "direct" | "transitive",
	duringRevalidation: (self) -> ()
}
```

A reactive graph object which can broadcast and receive updates among other
members of the reactive graph.

This type includes [`ScopedObject`](../../../memory/types/scopedobject), which
allows the lifetime and destruction order of the reactive graph to be analysed.

!!! note "Non-standard type syntax"
	The above type definition uses `self` to denote methods. At time of writing,
	Luau does not interpret `self` specially.

-----

## Members

<h3 markdown>
	dependencySet
	<span class="fusiondoc-api-type">
		: {[GraphObject]: unknown}
	</span>
</h3>

Everything this reactive graph object currently declares itself as dependent
upon.

<h3 markdown>
	dependentSet
	<span class="fusiondoc-api-type">
		: {[GraphObject]: unknown}
	</span>
</h3>

The reactive graph objects which declare themselves as dependent upon this
object.

<h3 markdown>
	invalidation
	<span class="fusiondoc-api-type">
		: "none" | "direct" | "transitive"
	</span>
</h3>

Encodes whether this graph object has been invalidated, and whether that's a
result of being invalidated directly, or having been transitively invalidated by
one of its dependencies.

-----

## Methods

<h3 markdown>
	duringRevalidation
	<span class="fusiondoc-api-type">
		-> ()
	</span>
</h3>

```Lua
function GraphObject:duringRevalidation(): ()
```

Called by Fusion while the graph object is in the process of being revalidated.
This is where logic to do with computational updates should be placed.

!!! fail "Restrictions"
	This method should finish without spawning new processes or blocking the 
	thread, though it is allowed to error.
