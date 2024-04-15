<nav class="fusiondoc-api-breadcrumbs">
	<span>General</span>
	<span>Types</span>
	<span>SpecialKey</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">SpecialKey</span>
</h1>

```Lua
export type SpecialKey = {
	type: "SpecialKey",
	kind: string,
	stage: "self" | "descendants" | "ancestor" | "observer",
	apply: (
		self,
		scope: Scope<unknown>,
		value: unknown,
		applyTo: Instance
	) -> ()
}
```

When used as the key in a [property table](../propertytable), defines a custom
operation to apply to the created Roblox instance.

!!! note "Non-standard type syntax"
	The above type definition uses `self` to denote methods. At time of writing,
	Luau does not interpret `self` specially.

-----

## Members

<h3 markdown>
	type
	<span class="fusiondoc-api-type">
		: "SpecialKey"
	</span>
</h3>

A type string which can be used for runtime type checking.


<h3 markdown>
	kind
	<span class="fusiondoc-api-type">
		: string
	</span>
</h3>

A more specific type string which can be used for runtime type checking. This
can be used to tell types of special key apart.

<h3 markdown>
	stage
	<span class="fusiondoc-api-type">
		: "self" | "descendants" | "ancestor" | "observer"
	</span>
</h3>

Describes the type of operation, which subsequently determines when it's applied
relative to other operations.

- `self` runs before parenting any instances
- `descendants` runs once descendants are parented, but before this instance is
parented to its ancestor
- `ancestor` runs after all parenting operations are complete
- `observer` runs after all other operations, so the final state of the instance
can be observed

-----

## Methods

<h3 markdown>
	apply
	<span class="fusiondoc-api-type">
		-> ()
	</span>
</h3>

```Lua
function SpecialKey:apply(
	self,
	scope: Scope<unknown>,
	value: unknown,
	applyTo: Instance
): ()
```

Called to apply this operation to an instance. `value` is the value from the
property table, and `applyTo` is the instance to apply the operation to.

The given `scope` is cleaned up when the operation is being unapplied, including
when the instance is destroyed. Operations should use the scope to clean up any
connections or undo any changes they cause.