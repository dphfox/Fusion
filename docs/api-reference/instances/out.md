<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">Instances</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-code-24:</span>
	<span class="fusiondoc-api-name">Out</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">function</span>
		<span class="fusiondoc-api-pill-since">since v0.2</span>
	</span>
</h1>

Given a property name, returns a [special key](./specialkey.md) which outputs
the value of properties with that name. It should be used with a [value](../state/value.md).

```Lua
(propertyName: string) -> SpecialKey
```

-----

## Parameters

- `propertyName` - The name of the property to output the value of.

-----

## Returns

A special key which runs at the `observer` stage. When applied to an instance,
it sets the value object equal to the property with the given name. It then
listens for further changes and updates the value object accordingly.

-----

## Example Usage

```Lua
local userText = Value()

New "TextBox" {
    [Out "Text"] = userText
}

Observer(userText):onChange(function()
    print("The user typed:", userText:get())
end)
```