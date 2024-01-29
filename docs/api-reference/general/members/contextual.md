<nav class="fusiondoc-api-breadcrumbs">
	<span>General</span>
	<span>Members</span>
	<span>Contextual</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">Contextual</span>
	<a href="../../types/contextual" class="fusiondoc-api-type">
		-> Contextual&lt;T&gt;
	</a>
</h1>

```Lua
function Fusion.Contextual<T>(
	defaultValue: T
): Contextual<T>
```

Constructs and returns a new [contextual](../../types/contextual).

-----

## Parameters

<h3 markdown>
	defaultValue
	<span class="fusiondoc-api-type">
		: T
	</span>
</h3>

The value which `Contextual:now()` should return if no value has been specified
by `Contextual:is():during()`.

-----

<h2 markdown>
	Returns
	<a href="../../types/contextual" class="fusiondoc-api-type">
		-> Contextual&lt;T&gt;
	</a>
</h2>

A freshly constructed contextual.

-----

## Learn More

- [Sharing Values tutorial](../../../../tutorials/best-practices/sharing-values)