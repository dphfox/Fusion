<nav class="fusiondoc-api-breadcrumbs">
	<span>General</span>
	<span>Types</span>
	<span>Contextual</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">Contextual</span>
</h1>

```Lua
export type Contextual<T> = {
	type: "Contextual",
	now: (self) -> T,
	is: (self, newValue: T) -> {
		during: <R, A...>(self, callback: (A...) -> R, A...) -> R
	}
}
```

An object representing a widely-accessible value, which can take on different
values at different times in different coroutines.

!!! note "Non-standard type syntax"
	The above type definition uses `self` to denote methods. At time of writing,
	Luau does not interpret `self` specially.

-----

## Fields

<h3 markdown>
	type
	<span class="fusiondoc-api-type">
		: "Contextual"
	</span>
</h3>

A type string which can be used for runtime type checking.

-----

## Methods

<h3 markdown>
	now
	<span class="fusiondoc-api-type">
		-> T
	</span>
</h3>

```Lua
function Contextual:now(): T
```

Returns the current value of this contextual. This varies based on when the
function is called, and in what coroutine it was called.

<h3 markdown>
	is/during
	<span class="fusiondoc-api-type">
		-> R
	</span>
</h3>

```Lua
function Contextual:is(
	newValue: T
): {
	during: <R, A...>(
		self,
		callback: (A...) -> R,
		A...
	) -> R
}
```

Runs the `callback` with the arguments `A...` and returns the value the callback
returns (`R`). The `Contextual` will appear to be `newValue` in the callback,
unless it's overridden by another `:is():during()` call.

-----

## Learn More

- [Sharing Values tutorial](../../../../tutorials/best-practices/sharing-values)