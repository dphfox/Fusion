<nav class="fusiondoc-api-breadcrumbs">
	<span>Roblox</span>
	<span>Members</span>
	<span>Child</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">Child</span>
	<span class="fusiondoc-api-type">
		-> <a href="../../types/child">Child</a>
	</span>
</h1>

```Lua
function Fusion.Child(
	child: Child
): Child
```

Returns the [child](../../types/child) passed into it.

This function does no processing. It only serves as a hint to the Luau type
system, constraining the type of the argument.

-----

## Parameters

<h3 markdown>
	child
	<span class="fusiondoc-api-type">
		: <a href="../../types/child">Child</a>
	</span>
</h3>

The argument whose type should be constrained.

-----

<h2 markdown>
	Returns
	<span class="fusiondoc-api-type">
		-> <a href="../../types/child">Child</a>
	</span>
</h2>

The argument with the newly cast static type.

-----

## Learn More

- [Parenting tutorial](../../../../tutorials/roblox/parenting)