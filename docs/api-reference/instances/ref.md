<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">Instances</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-key-24:</span>
	<span class="fusiondoc-api-name">Ref</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">special key</span>
		<span class="fusiondoc-api-pill-since">since v0.2</span>
	</span>
</h1>

When applied to an instance, outputs the instance to a state object. It should
be used with a [value](../state/value.md).

-----

## Example Usage

```Lua
local myRef = Value()

New "Part" {
    [Ref] = myRef
}

print(myRef:get()) --> Part
```

-----

## Technical Details

This special key runs at the `observer` stage.

On cleanup, the state object is reset to nil, in order to avoid potential
memory leaks.
