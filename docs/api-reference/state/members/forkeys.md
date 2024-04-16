<nav class="fusiondoc-api-breadcrumbs">
	<span>State</span>
	<span>Members</span>
	<span>ForKeys</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">ForKeys</span>
	<span class="fusiondoc-api-type">
		-> <a href="../../../state/types/for">For</a>&lt;KO, V&gt;
	</span>
</h1>

```Lua
function Fusion.ForKeys<KI, KO, V, S>(
	scope: Scope<S>,
	inputTable: UsedAs<{[KI]: V}>,
	processor: (Use, Scope<S>, key: KI) -> KO
) -> For<KO, V>
```

Constructs and returns a new [For state object](../../types/for) which processes
keys and preserves values.

!!! success "Use scoped() method syntax"
	This function is intended to be accessed as a method on a scope:
	```Lua
	local forObj = scope:ForKeys(inputTable, processor)
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
	inputTable
	<span class="fusiondoc-api-type">
		: <a href="../../../state/types/usedas">UsedAs</a>&lt;{[KI]: V}&gt;
	</span>
</h3>

The table which will provide the input keys and input values for this object.

If it is a state object, this object will respond to changes in that state.

<h3 markdown>
	processor
	<span class="fusiondoc-api-type">
		: (<a href="../../../memory/types/use">Use</a>, 
		<a href="../../../memory/types/scope">Scope</a>&lt;S&gt;,
		key: KI) -> KO
	</span>
</h3>

Accepts a `KI` key from the input table, and returns the `KO` key that should
appear in the output table.

The processor is given a [use function](../../../memory/types/use) for including
other objects in the computation, and a [scope](../../../memory/types/scope) for
queueing destruction tasks to run on re-computation. The given scope has the
same methods as the scope used to create the whole object.

-----

<h2 markdown>
	Returns
	<span class="fusiondoc-api-type">
		-> <a href="../../../state/types/for">For</a>&lt;KO, V&gt;
	</span>
</h2>

A freshly constructed For state object.

-----

## Learn More

- [ForKeys tutorial](../../../../tutorials/tables/forkeys)