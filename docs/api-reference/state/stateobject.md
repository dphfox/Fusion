<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">State</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-checklist-24:</span>
	<span class="fusiondoc-api-name">StateObject</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">type</span>
		<span class="fusiondoc-api-pill-since">since v0.2</span>
	</span>
</h1>

A dependency that provides a single stateful value; the dependency updates when
the value changes state.

Note that state objects do not expose a public interface for accessing their
interior value - the standard way of doing this is by using a
[use callback](./use.md) such as the [peek function](./peek.md).

```Lua
Dependency & {
	type: "State",
	kind: string
}
```

-----

## Fields

- `type` - uniquely identifies state objects for runtime type checks
- `kind` - holds a more specific type name for different kinds of state object

-----

## Example Usage

```Lua
-- these are examples of objects which are state objects
local value: StateObject = Value(5)
local computed: StateObject = Computed(function(use)
	return "foo"
end)
```