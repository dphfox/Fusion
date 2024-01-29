<nav class="fusiondoc-api-breadcrumbs">
	<span>State</span>
	<span>Members</span>
	<span>Computed</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">Computed</span>
	<a href="../../types/computed" class="fusiondoc-api-type">
		-> Computed&lt;T&gt;
	</a>
</h1>

```Lua
function Fusion.Computed<T, S>(
	scope: Scope<S>,
	processor: (Use, Scope<S>) -> T
) -> Computed<T>
```

Constructs and returns a new [computed state object](../../types/computed).

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
	processor
	<span class="fusiondoc-api-type">
		: (<a href="../../../memory/types/use">Use</a>, 
		<a href="../../../memory/types/scope">Scope&lt;S&gt;</a>) -> T
	</span>
</h3>

Computes the value that will be used by the computed. The processor is given a
[use function](../../../memory/types/use) for including other objects in the
computation, and a [scope](../../../memory/types/scope) for queueing destruction
tasks to run on re-computation. The given scope has the same methods as the
scope used to create the computed.

-----

<h2 markdown>
	Returns
	<a href="../../types/value" class="fusiondoc-api-type">
		-> Computed&lt;T&gt;
	</a>
</h2>

A freshly constructed computed state object.

-----

## Learn More

- [Computeds tutorial](../../../../tutorials/fundamentals/computeds)