<nav class="fusiondoc-api-breadcrumbs">
	<span>Roblox</span>
	<span>Members</span>
	<span>Out</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">Out</span>
	<span class="fusiondoc-api-type">
		-> <a href="../../types/specialkey">SpecialKey</a>
	</span>
</h1>

```Lua
function Fusion.Out(
	propertyName: string
): SpecialKey
```

Given an property name, returns a [special key](../../types/specialkey) which 
can output values from properties of that name.

When paired with a [value object](../../../state/types/value) in a
[property table](../../types/propertytable), the special key sets the value when
the property changes.

-----

## Parameters

<h3 markdown>
	propertyName
	<span class="fusiondoc-api-type">
		: string
	</span>
</h3>

The name of the property that the special key should target.

-----

<h2 markdown>
	Returns
	<span class="fusiondoc-api-type">
		-> <a href="../../types/specialkey">SpecialKey</a>
	</span>
</h2>

A special key for outputting values from properties of that name.

-----

## Learn More

- [Outputs tutorial](../../../../tutorials/roblox/outputs)