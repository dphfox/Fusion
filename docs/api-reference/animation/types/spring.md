<nav class="fusiondoc-api-breadcrumbs">
	<span>Animation</span>
	<span>Types</span>
	<span>Spring</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">Spring</span>
</h1>

```Lua
export type Spring<T> = StateObject<T> & Dependent & {
	kind: "Spring",
	setPosition: (self, newPosition: T) -> (),
	setVelocity: (self, newVelocity: T) -> (),
	addVelocity: (self, deltaVelocity: T) -> ()
}
```

A specialised [state object](../stateobject) for following a goal state smoothly
over time, using physics to shape the motion.

In addition to the standard state object interfaces, this object is a 
[dependent](../dependent) so it can receive updates from the goal state.

The methods on this type allow for direct control over the position and velocity
of the motion. Other than that, this type is of limited utility outside of
Fusion itself.

-----

## Members

<h3 markdown>
	kind
	<span class="fusiondoc-api-type">
		: "Spring"
	</span>
</h3>

A more specific type string which can be used for runtime type checking. This
can be used to tell types of state object apart.

-----

## Methods

<h3 markdown>
	setPosition
	<span class="fusiondoc-api-type">
		-> ()
	</span>
</h3>

```Lua
function Spring:setPosition(
	newPosition: T
): ()
```

Immediately snaps the spring to the given position. The position must have the
same `typeof()` as the goal state.

<h3 markdown>
	setVelocity
	<span class="fusiondoc-api-type">
		-> ()
	</span>
</h3>

```Lua
function Spring:setVelocity(
	newVelocity: T
): ()
```

Overwrites the spring's velocity without changing its position. The velocity
must have the same `typeof()` as the goal state.

<h3 markdown>
	addVelocity
	<span class="fusiondoc-api-type">
		-> ()
	</span>
</h3>

```Lua
function Spring:addVelocity(
	deltaVelocity: T
): ()
```

Appends to the spring's velocity without changing its position. The velocity
must have the same `typeof()` as the goal state.

-----

## Learn More

- [Springs tutorial](../../../../tutorials/animation/springs)