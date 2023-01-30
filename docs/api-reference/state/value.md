<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">State</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-package-24:</span>
	<span class="fusiondoc-api-name">Value</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">state object</span>
		<span class="fusiondoc-api-pill-since">since v0.2</span>
	</span>
</h1>

Stores a single value which can be updated at any time.

```Lua
(
	initialValue: T
) -> Value<T>
```

-----

## Parameters

- `initialValue` - The value that should be initially stored after construction.

-----

## Methods

<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

### :octicons-code-24: Value:get()

Returns the current value stored in the state object.

If dependencies are being captured (e.g. inside a computed callback), this state
object will also be added as a dependency.

```Lua
(asDependency: boolean?) -> T
```

#### Parameters

- `asDependency` - If this is explicitly set to false, no dependencies will be
captured.

-----

<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

### :octicons-code-24: Value:set()

Replaces the currently stored value, updating any other state objects that
depend on this value object. The value is stored directly, and no cloning or
alteration is done.

If the new value is the same as the old value, other state objects won't be
updated.

```Lua
(newValue: T) -> ()
```

#### Parameters

- `newValue` - The new value to be stored.

??? note "Table sameness"
	Updates are always sent out when setting a table value, because it's much
	more difficult to evaluate if two tables are the same. Therefore, this
	method is conservative and labels all tables as different, even
	compared to themselves.

??? caution "Legacy parameter: force"
	Originally, a second `force` parameter was available in Fusion 0.1 so that
	updates could forcibly be sent out, even when the new value was the same as
	the old value. This is because Fusion 0.1 used equality to evaluate sameness
	for all data types, including tables. This was problematic as many users
	attempted to `:get()` the table value, modify it, and `:set()` it back into
	the object, which would not cause an update as the table reference did not
	change.

	Fusion 0.2 uses a different sameness definition for tables to alleviate this
	problem. As such, there is no longer a good reason to use this parameter,
	and so it is not currently recommended for use. For backwards compatibility,
	it will remain for the time being, but do not depend on it for new work.

-----

## Example Usage

```Lua
local numCoins = Value(50) -- start off with 50 coins
print(numCoins:get()) --> 50

numCoins:set(10)
print(numCoins:get()) --> 10
```