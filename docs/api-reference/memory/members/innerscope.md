<nav class="fusiondoc-api-breadcrumbs">
	<span>Memory</span>
	<span>Members</span>
	<span>innerScope</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">innerScope</span>
	<span class="fusiondoc-api-type">
		-> <a href="../../types/scope">Scope</a>&lt;T&gt;
	</span>
</h1>

```Lua
function Fusion.innerScope<Existing, AddMethods...>(
	existing: Scope<Existing>,
	...: (AddMethods & {})...
): Scope<merge(Existing, AddMethods...)>
```

Returns a blank [scope](../../types/scope) with the same methods as an existing
scope, plus some optional additional methods which are merged in to only the
new scope.

Unlike [deriveScope](../derivescope), the returned scope is an inner scope of 
the original scope. It exists until either the user calls `doCleanup` on it, or
the original scope is cleaned up.

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
	existing
	<span class="fusiondoc-api-type">
		: <a href="../../types/scope">Scope</a>&lt;T&gt;
	</span>
</h3>

An existing scope, whose methods should be re-used for the new scope.

<h3 markdown>
	...
	<span class="fusiondoc-api-type">
		: AddMethods...
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

A blank inner scope with the same methods as the existing scope, plus the
extra methods provided.

-----

## Learn More

- [Scopes tutorial](../../../../tutorials/fundamentals/scopes)