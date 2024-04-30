<nav class="fusiondoc-api-breadcrumbs">
	<span>State</span>
	<span>Members</span>
	<span>peek</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">peek</span>
	<span class="fusiondoc-api-type">
		: <a href="../../types/use">Use</a>
	</span>
</h1>

```Lua
function Fusion.peek<T>(
	target: UsedAs<T>
): T
```

Extract a value of type `T` from its input.

This is a general-purpose implementation of [`Use`](../../types/use). It does
not do any extra processing or book-keeping beyond what is required to determine
the returned value.

!!! warning "Specific implementations"
	If you're given a specific implementation of `Use` by an API, it's highly
	likely that you are expected to use that implementation instead of `peek()`.

	This applies to reusable code too. It's often best to ask for a `Use`
	callback if your code needs to extract values, so an appropriate
	implementation can be passed in. 
	
	Alternatively for reusable code, you can avoid extracting values entirely,
	and expect the user to do it prior to calling your code. This can work well
	if you unconditionally use all inputs, but beware that you may end up
	extracting more values than you need - this can have performance
	implications.

-----

## Parameters

<h3 markdown>
	target
	<span class="fusiondoc-api-type">
		: <a href="../../types/usedas">UsedAs</a>&lt;T&gt;
	</span>
</h3>

The abstract representation of `T` to extract a value from.

-----

<h2 markdown>
	Returns
	<span class="fusiondoc-api-type">
		-> T
	</span>
</h2>

The current value of `T`, derived from `target`.

-----

## Learn More

- [Values tutorial](../../../../tutorials/fundamentals/values/)