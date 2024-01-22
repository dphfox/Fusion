<nav class="fusiondoc-api-breadcrumbs">
	<span>Memory</span>
	<span>Types</span>
	<span>ScopeLifetime</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">ScopeLifetime</span>
</h1>

```Lua
export type ScopeLifetime = {
	scope: Scope<unknown>?
}
```

An object which uses a [scope](../../types/scope) to dictate how long it lives.

-----

## Members

<h2 markdown>
	scope
	<a href="../../types/scope" class="fusiondoc-api-type">
		: Scope&lt;unknown&gt;?
	</span>
</h2>

The scope which this object was constructed within, or `nil` if the object has
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