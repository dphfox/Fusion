<nav class="fusiondoc-api-breadcrumbs">
	<span>State</span>
	<span>Members</span>
	<span>Observer</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">Observer</span>
	<span class="fusiondoc-api-type">
		-> <a href="../../../state/types/Observer">Observer</a>
	</span>
</h1>

```Lua
function Fusion.Observer(
	scope: Scope<unknown>,
	watching: unknown
) -> Observer
```

Constructs and returns a new [observer](../../types/observer).

!!! success "Use scoped() method syntax"
	This function is intended to be accessed as a method on a scope:
	```Lua
	local observer = scope:Observer(watching)
	```

-----

## Parameters

<h3 markdown>
	scope
	<span class="fusiondoc-api-type">
		: <a href="../../../memory/types/scope">Scope</a>&lt;unknown&gt;
	</span>
</h3>

The [scope](../../../memory/types/scope) which should be used to store
destruction tasks for this object.

<h3 markdown>
	watching
	<span class="fusiondoc-api-type">
		: unknown
	</span>
</h3>

The target that the observer should watch for changes.

!!! note "Works best with state objects"
	While non-[state object](../../../state/types/stateobject) values are
	accepted for compatibility, they won't be able to trigger updates.

-----

<h2 markdown>
	Returns
	<span class="fusiondoc-api-type">
		-> <a href="../../../state/types/observer">Observer</a>
	</span>
</h2>

A freshly constructed observer.

-----

## Learn More

- [Observers tutorial](../../../../tutorials/fundamentals/observers)