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
function Fusion.scoped<Methods...>(
	...: (Methods & {})...
): Scope<merge(Methods)>
```

Returns a blank [scope](../../types/scope). Any method tables passed in as
arguments are merged together, and used as the `__index` of the new scope, such
that they can be called with method notation on the created scope.

!!! note "Pseudo type"
	Luau doesn't have adequate syntax to represent this function.

!!! warning "Scopes are not unique"
	Fusion can recycle old unused scopes. This helps make scopes more
	lightweight, but it also means they don't uniquely belong to any part of
	your program.

	As a result, you shouldn't hold on to scopes after they've been cleaned up,
	and you shouldn't use them as unique identifiers anywhere.

-----

## Parameters

<h3 markdown>
	...
	<span class="fusiondoc-api-type">
		: Methods & {}
	</span>
</h3>

A series of tables, ideally including functions which take a scope as their
first parameter. Those functions will turn into methods on the scope.

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