<nav class="fusiondoc-api-breadcrumbs">
	<span>Roblox</span>
	<span>Members</span>
	<span>Attribute</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">Attribute</span>
	<span class="fusiondoc-api-type">
		-> <a href="../../types/specialkey">SpecialKey</a>
	</span>
</h1>

```Lua
function Fusion.Attribute(
	attributeName: string
): SpecialKey
```

Given an attribute name, returns a [special key](../../types/specialkey) which 
can modify attributes of that name.

When paired with a value in a [property table](../../types/propertytable), the
special key sets the attribute to that value.

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

A special key for modifying attributes of that name.