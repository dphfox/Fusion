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

This function must be used with the [attribute](./attribute.md) special key otherwise the callback will never run.

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
The handler is run with the attributes's value after every change.

-----

## Example Usage

```Lua
local currentBoxState = Value("enabled")

New "TextBox" {
	[Attribute "State"] = currentBoxState,
    [AttributeChange "State"] = function(newValue)
        print("State:", newValue)
    end
}
```