<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">State</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-checklist-24:</span>
	<span class="fusiondoc-api-name">Use</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">type</span>
		<span class="fusiondoc-api-pill-since">since v0.3</span>
	</span>
</h1>

The general function signature for unwrapping [state objects](./stateobject.md)
while transparently passing through other (constant) values.

Functions of this shape are often referred to as 'use callbacks', and are often
provided by dependency capturers such as [computeds](./computed.md) for the
purposes of tracking used state objects in a processor function.

```Lua
<T>(target: CanBeState<T>) -> T
```

-----

## Example Usage

```Lua
local foo: Value<number> = Value(2)
local doubleFoo = Computed(function(use: Fusion.Use)
	return use(foo) * 2
end)
```