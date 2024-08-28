<nav class="fusiondoc-api-breadcrumbs">
	<span>Graph</span>
	<span>Types</span>
	<span>GraphObject</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">GraphObject</span>
</h1>

```Lua
export type GraphObject = ScopedObject & {
	createdAt: number
	dependencySet: {[GraphObject]: unknown},
	dependentSet: {[GraphObject]: unknown},
	lastChange: number?,
	timeliness: "lazy" | "eager",
	validity: "valid" | "invalid" | "busy",
	_evaluate: (GraphObject, lastChange: number?) -> boolean
}
```

A reactive graph object which can broadcast and receive updates among other
members of the reactive graph.

This type includes [`ScopedObject`](../../../memory/types/scopedobject), which
allows the lifetime and destruction order of the reactive graph to be analysed.

!!! note "Non-standard type syntax"
	The above type definition uses `self` to denote methods. At time of writing,
	Luau does not interpret `self` specially.

-----

## Members

<h3 markdown>
	createdAt
	<span class="fusiondoc-api-type">
		: number
	</span>
</h3>

The `os.clock()` time of this object's construction, measured as early as
possible in the object's constructor.

<h3 markdown>
	dependencySet
	<span class="fusiondoc-api-type">
		: {[GraphObject]: unknown}
	</span>
</h3>

Everything this reactive graph object currently declares itself as dependent
upon.

<h3 markdown>
	dependentSet
	<span class="fusiondoc-api-type">
		: {[GraphObject]: unknown}
	</span>
</h3>

The reactive graph objects which declare themselves as dependent upon this
object.

<h3 markdown>
	lastChange
	<span class="fusiondoc-api-type">
		: number?
	</span>
</h3>

The `os.clock()` time of this object's most recent meaningful change, or `nil`
if the object is newly created.

<h3 markdown>
	timeliness
	<span class="fusiondoc-api-type">
		: "lazy" | "eager"
	</span>
</h3>

Describes when this object expects to be revalidated. Most objects should use
`lazy` timeliness to defer computation as late as possible. However, if it's
important for this object to respond to changes as soon as possible, for example
for the purposes of observation, then `eager` timeliness ensures that a
revalidation is dispatched as soon as possible.

<h3 markdown>
	validity
	<span class="fusiondoc-api-type">
		: "valid" | "invalid" | "busy"
	</span>
</h3>

Whether the most recent validation operation done on this graph object was a
revalidation or an invalidation. `busy` is used while the graph object is in
the middle of a revalidation.

-----

## Methods

<h3 markdown>
	_evaluate
	<span class="fusiondoc-api-type">
		-> boolean
	</span>
</h3>

```Lua
function GraphObject:_evaluate(): boolean
```

Called by Fusion while the graph object is in the process of being evaluated.
This is where logic to do with computational updates should be placed.

The return value is `true` when a 'meaningful change' occurs because of this
revalidation. A 'meaningful change' is one that would affect dependencies'
behaviour. This is used to efficiently skip over calculations for dependencies.

!!! failure "Restrictions"
	This method should finish without spawning new processes, blocking the 
	thread, or erroring.