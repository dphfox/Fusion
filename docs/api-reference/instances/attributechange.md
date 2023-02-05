<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">Instances</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-code-24:</span>
	<span class="fusiondoc-api-name">AttributeChange</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">function</span>
		<span class="fusiondoc-api-pill-since">since v0.3</span>
	</span>
</h1>

Given an attribute name, returns a [special key](./specialkey.md) which connects
to that attribute's change events.

```Lua
(attributeName: string) -> SpecialKey
```

-----

## Parameters

- `attributeName` - The name of the attribute to listen for changes to.

-----

## Returns

A special key which runs at the `observer` stage. When applied to an instance,
it connects to the attribute change signal on the instance for the given property.
The handler is run with the attribute's value after every change.

-----

## Example Usage

```Lua
New "TextBox" {
    [AttributeChange "State"] = function(newValue)
        print("The state attribute changed to:", newValue)
    end
}
```
