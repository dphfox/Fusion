<nav class="fusiondoc-api-breadcrumbs">
	<span>State</span>
	<span>Types</span>
	<span>Dependency</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">Dependency</span>
</h1>

```Lua
export type Dependency = ScopedObject & {
	dependentSet: {[Dependent]: unknown}
}
```

A reactive graph object which can broadcast updates. Other graph objects can
declare themselves as [dependent](../dependent) upon this object to receive
updates.

This type includes [`ScopedObject`](../../../memory/types/scopedobject), which
allows the lifetime and destruction order of the reactive graph to be analysed.

-----

## Members

<h3 markdown>
	dependentSet
	<span class="fusiondoc-api-type">
		: {[<a href="../dependent">Dependent</a>]: unknown}
	</span>
</h3>

The reactive graph objects which declare themselves as dependent upon this
object.