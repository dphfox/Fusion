<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">State</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-package-24:</span>
	<span class="fusiondoc-api-name">Observer</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">graph object</span>
		<span class="fusiondoc-api-pill-since">since v0.2</span>
	</span>
</h1>

Observes various updates and events on a given dependency.

```Lua
(
	observe: Dependency
) -> Observer
```

-----

## Parameters

- `observe: Dependency` - the dependency this observer should respond to

-----

## Object Methods

<p class="fusiondoc-api-pills">
	<span class="fusiondoc-api-pill-since">since v0.2</span>
</p>

### :octicons-code-24: Observer:onChange()

Connects the given callback as a change handler, and returns a function which
will disconnect the callback. The callback will run whenever the observed
dependency is updated.

```Lua
(callback: () -> ()) -> (() -> ())
```
#### Parameters

- `callback` - The function to call when a change is observed

!!! caution "Connection memory leaks"
	Make sure to disconnect any change handlers made using this function once
	you're done using them.

	As long as a change handler is connected, this observer and the dependency
	it observes will be held in memory in case further changes occur. This means,
	if you don't call the disconnect function, you may end up accidentally
	holding your state objects in memory forever after you're done using them.

-----

## Example Usage

```Lua
local numCoins = Value(50)

local coinObserver = Observer(numCoins)

local disconnect = coinObserver:onChange(function()
	print("coins is now:", numCoins:get())
end)

numCoins:set(25) -- prints 'coins is now: 25'

-- always clean up your connections!
disconnect()
```