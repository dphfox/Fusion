<nav class="fusiondoc-api-breadcrumbs">
	<span>State</span>
	<span>Types</span>
	<span>Dependent</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">Dependent</span>
</h1>

```Lua
export type Dependent = ScopedObject & {
	update: (self) -> boolean,
	dependencySet: {[Dependency]: unknown}
}
```

A reactive graph object which can add itself to [dependencies](../dependency)
and receive updates.

This type includes [`ScopedObject`](../../../memory/types/scopedobject), which
allows the lifetime and destruction order of the reactive graph to be analysed.

!!! note "Non-standard type syntax"
	The above type definition uses `self` to denote methods. At time of writing,
	Luau does not interpret `self` specially.

-----

## Members

<h3 markdown>
	dependencySet
	<span class="fusiondoc-api-type">
		: {[<a href="../dependency">Dependency</a>]: unknown}
	</span>
</h3>

Everything this reactive graph object currently declares itself as dependent
upon.

-----

## Methods

<h3 markdown>
	update
	<span class="fusiondoc-api-type">
		-> boolean
	</span>
</h3>

```Lua
function Dependent:update(): boolean
```

Called from a dependency when a change occurs. Returns `true` if the update
should propagate transitively through this object, or `false` if the update
should not continue through this object specifically.

!!! note "Return value ignored for non-dependencies"
	If this `Dependent` is not also a `Dependency`, the return value does
	nothing, as an object must be declarable as a dependency for other objects
	to receive updates from it.
