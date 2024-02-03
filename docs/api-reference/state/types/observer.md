<nav class="fusiondoc-api-breadcrumbs">
	<span>State</span>
	<span>Types</span>
	<span>Observer</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">Observer</span>
</h1>

```Lua
export type Observer = Dependent & {
	type: "Observer",
	onChange: (self, callback: () -> ()) -> (() -> ()),
	onBind: (self, callback: () -> ()) -> (() -> ())
}
```

A user-constructed [dependent](../dependent) that runs user code when its
[dependency](../dependency) is updated.

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
		-> ()
	</span>
</h3>

```Lua
function Value:set(
	newValue: T
): ()
```

Updates the value of this state object.

Other objects using the value are notified immediately of the change.

-----

## Learn More

- [Values tutorial](../../../../tutorials/fundamentals/values)