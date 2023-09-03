<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">State</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-checklist-24:</span>
	<span class="fusiondoc-api-name">Dependency</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">type</span>
		<span class="fusiondoc-api-pill-since">since v0.2</span>
	</span>
</h1>

A graph object which can send updates to [dependents](../dependent) on the
reactive graph.

Most often used with [state objects](../stateobject), though the reactive graph
does not require objects to store state.

```Lua
{
	dependentSet: Set<Dependent>
}
```

-----

## Example Usage

```Lua
-- these are examples of objects which are dependencies
local value: Dependency = Value(2)
local computed: Dependency = Computed(function(use)
	return use(value) * 2
end)

-- dependencies can be used with some internal functions such as updateAll()
updateAll(value)
```