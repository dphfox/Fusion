<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">State</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-checklist-24:</span>
	<span class="fusiondoc-api-name">StateObject</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">type</span>
		<span class="fusiondoc-api-pill-since">since v0.2</span>
	</span>
</h1>

A dependency that provides a single stateful value; the dependency updates when
the value changes state.

```Lua
Dependency & {
	type: "State",
	kind: string,
    get: (self, asDependency: boolean?) -> T
}
```

-----

## Fields

- `type` - uniquely identifies state objects for runtime type checks
- `kind` - holds a more specific type name for different kinds of state object

-----

## Methods

<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.1</span>
</p>

### :octicons-code-24: StateObject:get()

Returns the current value stored in the state object.

If dependencies are being captured (e.g. inside a computed callback), this state
object will also be added as a dependency.

```Lua
(asDependency: boolean?) -> T
```

-----

## Example Usage

```Lua
-- these are examples of objects which are state objects
local computed: StateObject = Computed(function()
	return "foo"
end)
local observer: StateObject = Observer(computed)
```

-----

## Automatic Dependency Manager

Fusion includes an automatic dependency manager which can detect when graph
objects are used in certain contexts and automatically form reactive graphs.

In order to do this, state objects should signal to the system when they are
being used. This can be done via the `useDependency()` function internally,
which should be called with the state object as the argument during execution of
the `:get()` method.

Furthermore, to help assist the dependency manager prevent cycles in the
reactive graph, state objects should register themselves with the system as soon
as they are created via the `initDependency()` function internally. This is
primarily used to prevent dependencies from being captured when they originate
from within the object which is doing the capturing.