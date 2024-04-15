<nav class="fusiondoc-api-breadcrumbs">
	<span>Memory</span>
	<span>Types</span>
	<span>Scope</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">Scope</span>
</h1>

```Lua
export type Scope<Constructors> = {unknown} & Constructors
```

A table collecting all objects created as part of an independent unit of code,
with optional `Constructors` as methods which can be called.

!!! warning "Scopes are not unique"
	Fusion can recycle old unused scopes. This helps make scopes more
	lightweight, but it also means they don't uniquely belong to any part of
	your program.

	As a result, you shouldn't hold on to scopes after they've been cleaned up,
	and you shouldn't use them as unique identifiers anywhere.

-----

## Learn More

- [Scopes tutorial](../../../../tutorials/fundamentals/scopes)