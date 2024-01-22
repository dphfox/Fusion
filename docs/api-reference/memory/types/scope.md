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