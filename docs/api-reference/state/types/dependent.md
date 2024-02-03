<nav class="fusiondoc-api-breadcrumbs">
	<span>State</span>
	<span>Types</span>
	<span>Dependent</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">Dependent</span>
</h1>

```Lua
export type Dependent = ScopeLifetime & {
	update: (Dependent) -> boolean,
	dependencySet: {[Dependency]: unknown}
}
```

A reactive graph object which can receive updates by adding [dependencies](../dependency).

This type includes [`ScopeLifetime`](../../../memory/types/scopelifetime), which
allows the lifetime and destruction order of the reactive graph to be analysed.

-----

## Members

<h2 markdown>
	dependencySet
	<span class="fusiondoc-api-type">
		: <a href="../../../memory/types/scope">Scope</a>&lt;unknown&gt;?
	</span>
</h2>

The reactive graph objects which declare themselves as dependent upon this
object.