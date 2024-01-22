<nav class="fusiondoc-api-breadcrumbs">
	<span>Memory</span>
	<span>Members</span>
	<span>deriveScope</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">deriveScope</span>
	<a href="../../types/scope" class="fusiondoc-api-type">
		-> Scope&lt;T&gt;
	</a>
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
	<a href="../../types/scope" class="fusiondoc-api-type">
		: Scope&lt;T&gt;
	</a>
</h3>

An existing scope, whose methods should be re-used for the new scope.

-----

<h2 markdown>
	Returns
	<a href="../../types/scope" class="fusiondoc-api-type">
		-> Scope&lt;T&gt;
	</a>
</h2>

A freshly-made, blank scope with the same methods.

-----

## Learn More

- [Scopes tutorial](../../../../tutorials/fundamentals/scopes)