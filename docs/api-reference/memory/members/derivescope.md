<nav class="fusiondoc-api-breadcrumbs">
	<span>Memory</span>
	<span>Members</span>
	<span>deriveScope</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">deriveScope</span>
	<span class="fusiondoc-api-type">
		-> <a href="../../types/scope">Scope</a>&lt;T&gt;
	</span>
</h1>

```Lua
function Fusion.deriveScope<T>(
	existing: Scope<T>
): Scope<T>
```

Creates a new [scope](../../types/scope) with the same methods as an existing
scope.

-----

## Parameters

<h3 markdown>
	existing
	<span class="fusiondoc-api-type">
		: <a href="../../types/scope">Scope</a>&lt;T&gt;
	</span>
</h3>

An existing scope, whose methods should be re-used for the new scope.

-----

<h2 markdown>
	Returns
	<span class="fusiondoc-api-type">
		-> <a href="../../types/scope">Scope</a>&lt;T&gt;
	</span>
</h2>

A freshly-made, blank scope with the same methods.

-----

## Learn More

- [Scopes tutorial](../../../../tutorials/fundamentals/scopes)