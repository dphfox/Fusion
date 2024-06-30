<nav class="fusiondoc-api-breadcrumbs">
	<span>Roblox</span>
	<span>Members</span>
	<span>Children</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">Children</span>
	<span class="fusiondoc-api-type">
		: <a href="../../types/specialkey">SpecialKey</a>
	</span>
</h1>

```Lua
Fusion.Children: SpecialKey
```

A [special key](../../types/specialkey) which parents other instances into this
instance.

When paired with a [`Child`](../../types/child) in a 
[property table](../../types/propertytable), the special key explores the
`Child` to find every `Instance` nested inside. It then parents those instances
under the instance which the special key was applied to.

In particular, this special key will recursively explore arrays and bind to any
[state objects](../../../state/types/stateobject).

-----

## Learn More

- [Parenting tutorial](../../../../tutorials/roblox/parenting)