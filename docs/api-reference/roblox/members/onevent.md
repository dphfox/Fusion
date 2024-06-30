<nav class="fusiondoc-api-breadcrumbs">
	<span>Roblox</span>
	<span>Members</span>
	<span>OnEvent</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">OnEvent</span>
	<span class="fusiondoc-api-type">
		-> <a href="../../types/specialkey">SpecialKey</a>
	</span>
</h1>

```Lua
function Fusion.OnEvent(
	eventName: string
): SpecialKey
```

Given an event name, returns a [special key](../../types/specialkey) which 
can listen for events of that name.

When paired with a callback in a [property table](../../types/propertytable),
the special key connects the callback to the event.

-----

## Parameters

<h3 markdown>
	eventName
	<span class="fusiondoc-api-type">
		: string
	</span>
</h3>

The name of the event that the special key should target.

-----

<h2 markdown>
	Returns
	<span class="fusiondoc-api-type">
		-> <a href="../../types/specialkey">SpecialKey</a>
	</span>
</h2>

A special key for listening to events of that name.

-----

## Learn More

- [Events tutorial](../../../../tutorials/roblox/events)