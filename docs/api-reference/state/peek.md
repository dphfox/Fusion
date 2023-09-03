<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">State</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-code-24:</span>
	<span class="fusiondoc-api-name">peek</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">function</span>
		<span class="fusiondoc-api-pill-since">since v0.3</span>
	</span>
</h1>

The most basic [use callback](./use.md), which returns the interior value of
state objects without adding any dependencies.

```Lua
<T>(target: CanBeState<T>) -> T
```

-----

## Parameters

- `target: CanBeState<T>` - The argument to attempt to unwrap.

-----

## Returns

If the argument is a state object, returns the interior value of the state
object. Otherwise, returns the argument itself.

-----

## Example Usage

```Lua
local thing = Value(5)

print(peek(thing)) --> 5
```