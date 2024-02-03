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
export type Dependency = ScopeLifetime & {
	dependentSet: Set<Dependent>
}
```

A reactive graph object which can broadcast updates to other reactive graph
objects.

This type includes [`ScopeLifetime`](../../../memory/types/scopelifetime), which
allows the lifetime and destruction order of the reactive graph to be analysed.

-----

## Members

<h2 markdown>
	dependentSet
	<span class="fusiondoc-api-type">
		: <a href="../../../memory/types/scope">Scope</a>&lt;unknown&gt;?
	</span>
</h2>

The reactive graph objects which declare themselves as dependent upon this
object.