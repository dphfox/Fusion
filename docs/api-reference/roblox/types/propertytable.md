<nav class="fusiondoc-api-breadcrumbs">
	<span>Roblox</span>
	<span>Types</span>
	<span>PropertyTable</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">PropertyTable</span>
</h1>

```Lua
export type PropertyTable = {[string | SpecialKey]: unknown}
```

A table of named instance properties and [special keys](../specialkey), which
can be passed to [`New`](../../members/new) to create an instance.

!!! warning "This type can be overly generic"
	In most cases, you should know what properties your code is looking for. In
	those cases, you should prefer to list out the properties explicitly, to
	document what your code needs.

	You should only use this type if you don't know what properties your code
	will accept.
