<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">Memory</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-code-24:</span>
	<span class="fusiondoc-api-name">scoped</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">function</span>
		<span class="fusiondoc-api-pill-since">since v0.3</span>
	</span>
</h1>

Creates and returns a blank cleanup table, with the `__index` metatable pointing
at the given list of constructors for syntax convenience.

```Lua
<T>(constructors: T) -> {Task} & T
```

!!! info "Approximated type"
	The return type of this function is approximate. Luau does not offer a way
	of annotating metatable types as of v0.3, so the type signature is
	intentionally incorrect to try and usefully annotate for common usage.

-----

## Parameters

- `constructors: T` - A table including constructors with cleanup tables as the
first parameter.

-----

## Example Usage

```Lua
local scope = scoped(Fusion)
local value = scope:Value(5)
doCleanup(scope)

-- equivalent to
local scope = {}
local value = Value(scope, 5)
doCleanup(scope)
```