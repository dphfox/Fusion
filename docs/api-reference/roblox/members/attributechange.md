<nav class="fusiondoc-api-breadcrumbs">
	<span>Roblox</span>
	<span>Members</span>
	<span>AttributeChange</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">AttributeChange</span>
	<span class="fusiondoc-api-type">
		-> <a href="../../types/specialkey">SpecialKey</a>
	</span>
</h1>

```Lua
function Fusion.AttributeChange(
	attributeName: string
): SpecialKey
```

Given an attribute name, returns a [special key](../../types/specialkey) which 
can listen to changes for attributes of that name.

When paired with a callback in a [property table](../../types/propertytable),
the special key connects the callback to the attribute's change event.

-----

## Parameters

<h3 markdown>
	attributeName
	<span class="fusiondoc-api-type">
		: string
	</span>
</h3>

The name of the attribute that the special key should target.

-----

<h2 markdown>
	Returns
	<span class="fusiondoc-api-type">
		-> <a href="../../types/specialkey">SpecialKey</a>
	</span>
</h2>

A special key for listening to changes for attributes of that name.