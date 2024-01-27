<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">State</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-checklist-24:</span>
	<span class="fusiondoc-api-name">Dependent</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">type</span>
		<span class="fusiondoc-api-pill-since">since v0.2</span>
	</span>
</h1>

A graph object which can receive updates from [dependecies](../dependency) on
the reactive graph.

Most often used with [state objects](../stateobject), though the reactive graph
does not require objects to store state.

```Lua
{
	dependencySet: Set<Dependency>,
    update: (self) -> boolean
}
```

-----

## Fields

- `dependencySet` - stores the graph objects which this object can receive
updates from

-----

## Methods

<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

### :octicons-code-24: Dependent:update()

Called when this object receives an update from one or more dependencies.

If this object is a dependency, and updates should be propagated to further
dependencies, this method should return true. Otherwise, to block further
updates from occuring (for example, because this object did not change value),
this method should return false.

```Lua
() -> boolean
```

-----

## Example Usage

```Lua
-- these are examples of objects which are dependents
local computed: Dependent = Computed(function(use)
	return "foo"
end)
local observer: Dependent = Observer(computed)
```