<nav class="fusiondoc-api-breadcrumbs">
	<span>Roblox</span>
	<span>Members</span>
	<span>New</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">New</span>
	<span class="fusiondoc-api-type">
		-> (<a href="../../types/propertytable">PropertyTable</a>) -> Instance
	</span>
</h1>

```Lua
function Fusion.New(
	className: string
): (
	props: PropertyTable
) -> Instance
```

Given a class name, returns a component for constructing instances of that
class.

In the property table, string keys are assigned as properties on the instance.
If the value is a [state object](../../../state/types/stateobject), it is
re-assigned every time the value of the state object changes.

Any [special keys](../../types/specialkey) present in the property table are
applied to the instance after string keys are processed, in the order specified
by their `stage`.

A special exception is made for assigning `Parent`, which is only assigned after
the `descendants` stage.

-----

## Parameters

<h3 markdown>
	className
	<span class="fusiondoc-api-type">
		: string
	</span>
</h3>

The kind of instance that should be constructed.

-----

<h2 markdown>
	Returns
	<span class="fusiondoc-api-type">
		-> (<a href="../../types/propertytable">PropertyTable</a>) -> Instance
	</span>
</h2>

A component that constructs instances of that type, accepting various properties
to customise each instance uniquely.

-----

## Learn More

- [New Instances tutorial](../../../../tutorials/roblox/new-instances)