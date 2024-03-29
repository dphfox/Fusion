<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">State</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-package-24:</span>
	<span class="fusiondoc-api-name">ForValues</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">state object</span>
		<span class="fusiondoc-api-pill-since">since v0.2</span>
	</span>
</h1>

Processes a table from another state object by transforming its values only.

```Lua
(
	input: CanBeState<{[K]: VI}>,
	valueProcessor: (Use, VI) -> (VO, M),
	valueDestructor: ((VO, M) -> ())?
) -> ForValues<K, VI, VO, M>
```

-----

## Parameters

- `input: CanBeState<{[K]: VI}>` - the table to be processed, either as a state
object or a constant value
- `valueProcessor: (Use, VI) -> (VO, M)` - transforms input values into new values,
optionally providing metadata for the destructor alone
- `valueDestructor: ((VO, M) -> ())?` - disposes of values generated by
`valueProcessor` when they are no longer in use

-----

## Example Usage

```Lua
local data = Value({
	one = 1,
	two = 2,
	three = 3,
	four = 4
})

local transformed = ForValues(data, function(use, value)
	local newValue = value * 2
	return newValue
end)

print(peek(transformed)) --> {ONE = 2, TWO = 4 ... }
```

-----

## Dependency Management

By default, ForValues runs the processor function once per value in the input,
then caches the result indefinitely. To specify the calculation should re-run
for the value when a state object changes value, the objects can be passed to
the [use callback](./use.md) passed to the processor function for that value.
The use callback will unwrap the value as normal, but any state objects will
become dependencies of that value.

-----

## Destructors

The `valueDestructor` callback, if provided, is called when this object swaps
out an old value for a newly-generated one. It is called with the old value as
the first parameter, and - if provided - an extra value returned from
`valueProcessor` as a customisable second parameter.

Destructors are required when working with data types that require destruction,
such as instances. Otherwise, they are optional, so not all calculations have to
specify destruction behaviour.

Fusion guarantees that values passed to destructors by default will never be
used again by the library, so it is safe to finalise them. This does not apply
to the customisable second parameter, which the user is responsible for handling
properly.

-----

## Optimisations

ForValues does not allow access to the keys of the input table. This guarantees
that all generated values are completely independent of the key they were
generated for. This means that values may be moved between keys instead of being
destroyed when their original key changes value. Values are only reused once -
values aren't copied when there are multiple occurences of the same input.