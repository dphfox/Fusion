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

<h2 markdown>
	scope
	<span class="fusiondoc-api-type">
		: <a href="../../types/scope">Scope</a>&lt;unknown&gt;?
	</span>
</h2>

The scope which this object was constructed with, or `nil` if the object has
been destroyed.

!!! note "Unchanged until destruction"
	The `scope` is expected to be set once upon construction. It should not be
	assigned to again, except when the scope is destroyed - at which point it
	should be set to `nil` to indicate that it no longer exists inside of a
	scope. This is typically done inside the `:destroy()` method, if it exists.

!!! tip "Double-destruction prevention"
	Fusion's objects throw
	[`destroyedTwice`](../../../general/errors/#destroyedtwice) if they detect
	a `nil` scope during`:destroy()`.

	It's strongly recommended that you emulate this behaviour if you're
	implementing your own objects, as this protects against double-destruction
	and exposes potential scoping issues further ahead of time.

-----

## Methods

<h2 markdown>
	destroy
	<span class="fusiondoc-api-type">
		-> ()
	</span>
</h2>

```Lua
function ScopedObject:destroy(): ()
```

Called from a dependency when a change occurs. Returns `true` if the update
should propagate transitively through this object, or `false` if the update
should not continue through this object specifically.