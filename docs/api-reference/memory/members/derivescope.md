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

Returns a blank [scope](../../types/scope) with the same methods as an existing
scope.

!!! warning "Scopes are not unique"
	Fusion can recycle old unused scopes. This helps make scopes more
	lightweight, but it also means they don't uniquely belong to any part of
	your program.

	As a result, you shouldn't hold on to scopes after they've been cleaned up,
	and you shouldn't use them as unique identifiers anywhere.

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

A blank scope with the same methods as the existing scope.

-----

## Learn More

- [Scopes tutorial](../../../../tutorials/fundamentals/scopes)