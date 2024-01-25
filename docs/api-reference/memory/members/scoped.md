<nav class="fusiondoc-api-breadcrumbs">
	<span>Memory</span>
	<span>Members</span>
	<span>scoped</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">scoped</span>
	<a href="../../types/scope" class="fusiondoc-api-type">
		-> Scope&lt;T&gt;
	</a>
</h1>

```Lua
function Fusion.scoped<T>(
	constructors: T
): Scope<T>
```

Creates and returns a blank [scope](../../types/scope), with the `__index`
metatable pointing at the given list of constructors for syntax convenience.

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
	<a href="../../types/scope" class="fusiondoc-api-type">
		-> Scope&lt;T&gt;
	</a>
</h2>

A freshly created, blank scope.

-----

## Learn More

- [Scopes tutorial](../../../../tutorials/fundamentals/scopes)