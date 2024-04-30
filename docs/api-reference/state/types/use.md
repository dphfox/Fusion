<nav class="fusiondoc-api-breadcrumbs">
	<span>State</span>
	<span>Types</span>
	<span>Use</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">Use</span>
</h1>

```Lua
export type Use = <T>(target: UsedAs<T>) -> T
```

A function which extracts a value of `T` from something that can be
[used as](../usedas) `T`.

The most generic implementation of this is
[the `peek()` function](../../members/peek), which performs this extraction with
no additional steps. 

However, certain APIs may provide their own implementation,
so they can perform additional processing for certain representations. Most
notably, [computeds](../../members/computed) provide their own `use()` function
which adds inputs to a watchlist, which allows them to re-calculate as inputs
change.

-----

## Parameters

<h3 markdown>
	target
	<span class="fusiondoc-api-type">
		: <a href="../usedas">UsedAs</a>&lt;T&gt;
	</span>
</h3>

The representation of `T` to extract a value from.

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
- [Computeds tutorial](../../../../tutorials/fundamentals/computeds/)