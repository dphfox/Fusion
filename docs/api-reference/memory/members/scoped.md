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
	Fusion can recycle old unused scopes. This helps make scopes more
	lightweight, but it also means they don't uniquely belong to any part of
	your program.

	As a result, you shouldn't hold on to scopes after they've been cleaned up,
	and you shouldn't use them as unique identifiers anywhere.

-----

## Parameters

<h3 markdown>
	constructors
	<span class="fusiondoc-api-type">
		: T
	</span>
</h3>

A table, ideally including functions which take a scope as their first
parameter. Those functions will turn into methods.

-----

<h2 markdown>
	Returns
	<span class="fusiondoc-api-type">
		-> <a href="../../types/scope">Scope</a>&lt;T&gt;
	</span>
</h2>

A blank scope with the specified methods.

-----

## Learn More

- [Scopes tutorial](../../../../tutorials/fundamentals/scopes)