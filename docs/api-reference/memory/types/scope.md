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

!!! note "Approximated type"
	Luau does not yet have syntax for annotating metatables, so scopes created
	with constructor methods cannot be represented in text.

!!! warning "Scopes are not unique"
	Fusion can recycle old unused scopes and return them from other functions.
	This reduces wasted memory while your program is running.

	However, it means this function doesn't always return a completely new
	scope, so you shouldn't save the scope anywhere or use it as an identifier.