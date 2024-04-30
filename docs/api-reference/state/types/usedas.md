<nav class="fusiondoc-api-breadcrumbs">
	<span>State</span>
	<span>Types</span>
	<span>UsedAs</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">UsedAs</span>
</h1>

```Lua
export type UsedAs<T> = T | StateObject<T>
```

Something which describes a value of type `T`. When it is [used](../use) in a
calculation, it becomes that value.

!!! success "Recommended"
	Instead of using one of the more specific variants, your code should aim to
	use this type as often as possible. It allows your logic to deal with many
	representations of values at once, 

-----

## Variants

- `T` - represents unchanging constant values
- [`StateObject<T>`](../stateobject) - represents dynamically updating values

-----

## Learn More

- [Components tutorial](../../../../tutorials/best-practices/components/)