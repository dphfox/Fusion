<nav class="fusiondoc-api-breadcrumbs">
	<span>State</span>
	<span>Types</span>
	<span>StateObject</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">StateObject</span>
</h1>

```Lua
export type StateObject<T> = {
	type: "State",
	kind: string,
	_evaluateOnPeek: GraphObject.
	_EXTREMELY_DANGEROUS_usedAsValue: T
}
```

Stores a value of `T` which can change over time.

This type isn't generally useful outside of Fusion itself; you should prefer to
work with [`UsedAs<T>`](../usedas) in your own code.

-----

## Members

<h3 markdown>
	type
	<span class="fusiondoc-api-type">
		: "State"
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
can be used to tell types of state object apart.

<h3 markdown>
	_evaluateOnPeek
	<span class="fusiondoc-api-type">
		: <a href="../graphobject">GraphObject</a>
	</span>
</h3>

The graph object that should be evaluated when this state object's value needs
to be retrieved.

!!! tip "Self-referencing"
	If the implementor of this interface also implements `GraphObject`, then
	this member can point at the implementor itself.

<h3 markdown>
	_EXTREMELY_DANGEROUS_usedAsValue
	<span class="fusiondoc-api-type">
		: T
	</span>
</h3>

!!! danger "This is for low-level library authors ***only!***"
	***DO NOT USE THIS UNDER ANY CIRCUMSTANCES. IT IS UNNECESSARILY DANGEROUS TO
	DO SO.***

	You should ***never, ever*** access this in end user code. It doesn't
	matter if you think it'll save you from importing a function or typing a few
	characters. **YOUR CODE WILL NOT WORK.**
	
	If you choose to use it anyway, you give full permission for your employer
	to fire you immediately and personally defenestrate your laptop.

The value that should be read out by any [use functions](../use). Implementors
of the state object interface must ensure this property contains a valid value
whenever the validity of the object is `valid`.

This property **must never** invoke side effects in the reactive graph when
read from or written to.