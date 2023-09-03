<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">Instances</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-code-24:</span>
	<span class="fusiondoc-api-name">AttributeOut</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">function</span>
		<span class="fusiondoc-api-pill-since">since v0.3</span>
	</span>
</h1>

Given an attribute name, returns a [special key](./specialkey.md) which outputs the value of
attribute's with that name. It should be used with a [value](../state/value.md) object.

```Lua
(attributeName: string) -> SpecialKey
```

-----

## Parameters

- `attributeName` - The name of the attribute to output the value of.

-----

## Returns

A special key which runs at the `observer` stage. When applied to an instance,
it sets the value object equal to the attribute with the given name. It then
listens for further changes and updates the value object accordingly.

-----

## Example Usage

```Lua
local ammo = Value()

New "Configuration" {
    [Attribute "Ammo"] = ammo,
    [AttributeOut "Ammo"] = ammo
}

Observer(ammo):onChange(function()
    print("Current ammo:", peek(ammo))
end)
```
