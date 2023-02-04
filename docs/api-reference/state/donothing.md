<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">State</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-code-24:</span>
	<span class="fusiondoc-api-name">doNothing</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">function</span>
		<span class="fusiondoc-api-pill-since">since v0.2</span>
	</span>
</h1>

No-op function - does nothing at all, and returns nothing at all. Intended for
use as a destructor when no destruction is needed.

```Lua
(...any) -> ()
```

-----

## Parameters

- `...` - Any objects.

-----

## Example Usage

```Lua
local foo = Computed(function()
	return workspace.Part
end, Fusion.doNothing)
```