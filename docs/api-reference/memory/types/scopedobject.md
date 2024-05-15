<nav class="fusiondoc-api-breadcrumbs">
	<span>Memory</span>
	<span>Types</span>
	<span>ScopedObject</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">ScopedObject</span>
</h1>

```Lua
export type ScopedObject = {
	scope: Scope<unknown>?,
	destroy: () -> ()
}
```

An object designed for use with [scopes](../../types/scope).

Objects satisfying this interface can be probed for information about their
lifetime and how long they live relative to other objects satisfying this
interface. 

These objects are also recognised by [`doCleanup`](../../members/docleanup).

-----

## Members

<h3 markdown>
	scope
	<span class="fusiondoc-api-type">
		: <a href="../../types/scope">Scope</a>&lt;unknown&gt;?
	</span>
</h3>

The scope which this object was constructed with, or `nil` if the object has
been destroyed.

!!! note "Unchanged until destruction"
	The `scope` is expected to be set once upon construction. It should not be
	assigned to again, except when the scope is destroyed - at which point it
	should be set to `nil` to indicate that it no longer exists inside of a
	scope. This is typically done inside of `oldestTask`.

<h3 markdown>
	oldestTask
	<span class="fusiondoc-api-type">
		: unknown
	</span>
</h3>

The value inside of `scope` representing the point at which the scoped object
will be destroyed.

!!! note "Unchanged until destruction"
	The `oldestTask` is expected to be set once upon construction. It should not
	be assigned to again.

	`oldestTask` is typically a callback that cleans up the object, but it's
	typed ambiguously here as it is only used as a reference for lifetime
	analysis, representing the point beyond which the object can be considered
	completely destroyed. It shouldn't be used for much else.

-----

## Learn More

- [Scopes tutorial](../../../../tutorials/fundamentals/scopes)