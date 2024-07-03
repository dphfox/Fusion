<nav class="fusiondoc-api-breadcrumbs">
	<span>State</span>
	<span>Types</span>
	<span>Value</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">Value</span>
</h1>

```Lua
export type Value<T> = StateObject<T> & {
	kind: "State",
 	set: (self, newValue: T) -> ()
}
```

A specialised [state object](../stateobject) which allows regular Luau code to
control its value.

!!! note "Non-standard type syntax"
	The above type definition uses `self` to denote methods. At time of writing,
	Luau does not interpret `self` specially.

-----

## Members

<h3 markdown>
	kind
	<span class="fusiondoc-api-type">
		: "Value"
	</span>
</h3>

A more specific type string which can be used for runtime type checking. This
can be used to tell types of state object apart.

-----

## Methods

<h3 markdown>
	set
	<span class="fusiondoc-api-type">
		-> T
	</span>
</h3>

```Lua
function Value:set(
	newValue: T
): T
```

Updates the value of this state object. Other objects using the value are
notified of the change.

The `newValue` is always returned, so that `:set()` can be used to capture
values inside of expressions.

-----

## Learn More

- [Values tutorial](../../../../tutorials/fundamentals/values)