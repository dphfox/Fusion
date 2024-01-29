<nav class="fusiondoc-api-breadcrumbs">
	<span>State</span>
	<span>Members</span>
	<span>Value</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">Value</span>
	<a href="../../types/value" class="fusiondoc-api-type">
		-> Value&lt;T&gt;
	</a>
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
	<a href="../../../memory/types/scope" class="fusiondoc-api-type">
		: Scope&lt;S&gt;
	</a>
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
	<a href="../../types/value" class="fusiondoc-api-type">
		-> Value&lt;T&gt;
	</a>
</h2>

A freshly constructed value state object.

-----

## Learn More

- [Values tutorial](../../../../tutorials/fundamentals/values)