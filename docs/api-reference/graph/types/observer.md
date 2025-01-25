<nav class="fusiondoc-api-breadcrumbs">
	<span>Graph</span>
	<span>Types</span>
	<span>Observer</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">Observer</span>
</h1>

```Lua
export type Observer = GraphObject & {
	type: "Observer",
	timeliness: "eager",
	onChange: (self, callback: () -> ()) -> (() -> ()),
	onBind: (self, callback: () -> ()) -> (() -> ())
}
```

A [graph object](../graphobject) that runs user code when it's updated by the
reactive graph.

!!! note "Non-standard type syntax"
	The above type definition uses `self` to denote methods. At time of writing,
	Luau does not interpret `self` specially.

-----

## Members

<h3 markdown>
	type
	<span class="fusiondoc-api-type">
		: "Observer"
	</span>
</h3>

A type string which can be used for runtime type checking.

-----

## Methods

<h3 markdown>
	onChange
	<span class="fusiondoc-api-type">
		-> (() -> ())
	</span>
</h3>

```Lua
function Observer:onChange(
	callback: () -> ()
): (() -> ())
```

Registers the callback to run when an update is received. 

The returned function will unregister the callback.

<h3 markdown>
	onBind
	<span class="fusiondoc-api-type">
		-> (() -> ())
	</span>
</h3>

```Lua
function Observer:onBind(
	callback: () -> ()
): (() -> ())
```

Runs the callback immediately, and registers the callback to run when an update
is received.

The returned function will unregister the callback.

-----

## Learn More

- [Observers tutorial](../../../../tutorials/fundamentals/observers)