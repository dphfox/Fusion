<nav class="fusiondoc-api-breadcrumbs">
	<span>Roblox</span>
	<span>Members</span>
	<span>OnChange</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">OnChange</span>
	<span class="fusiondoc-api-type">
		-> <a href="../../types/specialkey">SpecialKey</a>
	</span>
</h1>

```Lua
function Fusion.OnChange(
	propertyName: string
): SpecialKey
```

Given an property name, returns a [special key](../../types/specialkey) which 
can listen to changes for properties of that name.

When paired with a callback in a [property table](../../types/propertytable),
the special key connects the callback to the property's change event.

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

A special key for listening to changes for properties of that name.

-----

## Learn More

- [Change Events tutorial](../../../../tutorials/roblox/change-events)