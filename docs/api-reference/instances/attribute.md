<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">Instances</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-key-24:</span>
	<span class="fusiondoc-api-name">Attribute</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">special key</span>
		<span class="fusiondoc-api-pill-since">since v0.3</span>
	</span>
</h1>

A [special key](./specialkey.md) for adding attributes to instances.

-----

## Parameters

```lua
(attributeName: string) -> SpecialKey
```

-----

## Example Usage

```lua
local ammoValue = Value(10)
local label = New "TextLabel" {
	[Attribute "Ammo"] = ammoValue
}

print(label:GetAttribute("Ammo")) -- 10
```

-----

## Technical Details

This special key runs at the `self` stage.

-----
