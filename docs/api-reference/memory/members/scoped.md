<nav class="fusiondoc-api-breadcrumbs">
	<span>Memory</span>
	<span>Members</span>
	<span>scoped</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">scoped</span>
	<span class="fusiondoc-api-type">
		-> <a href="../../types/scope">Scope</a>&lt;T&gt;
	</span>
</h1>

```Lua
function Fusion.scoped<T>(
	constructors: T
): Scope<T>
```

Returns a blank [scope](../../types/scope), with the `__index` metatable
pointing at the given list of constructors for syntax convenience.

!!! warning "Scopes are not unique"
	Fusion can recycle old unused scopes and return them from this function.
	This reduces wasted memory while your program is running.

	However, it means this function doesn't always return a completely new
	scope, so you shouldn't save the scope anywhere or use it as an identifier.

-----

## Parameters

<h3 markdown>
	constructors
	<span class="fusiondoc-api-type">
		: T
	</span>
</h3>

A table, ideally including functions which take a scope as their first
parameter.

-----

<h2 markdown>
	Returns
	<span class="fusiondoc-api-type">
		-> <a href="../../types/scope">Scope</a>&lt;T&gt;
	</span>
</h2>

A freshly created, blank scope.

-----

## Learn More

- [Scopes tutorial](../../../../tutorials/fundamentals/scopes)