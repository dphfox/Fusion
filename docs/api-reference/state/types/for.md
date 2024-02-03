<nav class="fusiondoc-api-breadcrumbs">
	<span>State</span>
	<span>Types</span>
	<span>For</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">For</span>
</h1>

```Lua
export type For<KO, VO> = StateObject<{[KO]: VO}> & Dependent & {
	kind: "For"
}
```

A specialised [state object](../stateobject) for tracking multiple values
computed from user-defined computations, which are merged into an output table.

In addition to the standard state object interfaces, this object is a 
[dependent](../dependent) so it can receive updates from objects used as
part of any of the computations.

This type isn't generally useful outside of Fusion itself.

-----

## Members

<h3 markdown>
	kind
	<span class="fusiondoc-api-type">
		: "For"
	</span>
</h3>

A more specific type string which can be used for runtime type checking. This
can be used to tell types of state object apart.

-----

## Learn More

- [ForValues tutorial](../../../../tutorials/tables/forvalues)
- [ForKeys tutorial](../../../../tutorials/tables/forkeys)
- [ForPairs tutorial](../../../../tutorials/tables/forpairs)