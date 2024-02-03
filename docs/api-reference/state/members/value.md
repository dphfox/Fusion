<nav class="fusiondoc-api-breadcrumbs">
	<span>State</span>
	<span>Members</span>
	<span>Value</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">Value</span>
	<span class="fusiondoc-api-type">
		-> <a href="../../types/value">Value</a>&lt;T&gt;
	</span>
</h1>

```Lua
function Fusion.Value<T>(
	scope: Scope<unknown>,
	initialValue: T
) -> Value<T>
```

Constructs and returns a new [value state object](../../types/value).

!!! success "Use scoped() method syntax"
	This function is intended to be accessed as a method on a scope:
	```Lua
	local computed = scope:Computed(processor)
	```

-----

## Parameters

<h3 markdown>
	scope
	<span class="fusiondoc-api-type">
		: <a href="../../../memory/types/scope">Scope</a>&lt;S&gt;
	</span>
</h3>

The [scope](../../../memory/types/scope) which should be used to store
destruction tasks for this object.

<h3 markdown>
	initialValue
	<span class="fusiondoc-api-type">
		: T
	</span>
</h3>

The initial value that will be stored until the next value is `:set()`.

-----

<h2 markdown>
	Returns
	<span class="fusiondoc-api-type">
		-> <a href="../../types/value">Value</a>&lt;T&gt;
	</span>
</h2>

A freshly constructed value state object.

-----

## Learn More

- [Values tutorial](../../../../tutorials/fundamentals/values)