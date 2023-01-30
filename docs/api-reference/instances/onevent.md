<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">Instances</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-code-24:</span>
	<span class="fusiondoc-api-name">OnEvent</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">function</span>
		<span class="fusiondoc-api-pill-since">since v0.1</span>
	</span>
</h1>

Given an event name, returns a [special key](./specialkey.md) which connects to
events of that name. It should be used with a handler callback, which may accept
arguments from the event.

```Lua
(eventName: string) -> SpecialKey
```

-----

## Parameters

- `eventName` - the name of the event to connect to

-----

## Returns

A special key which runs at the `observer` stage. When applied to an instance,
it connects to the event on the instance of the given name. The handler is run
with the event's arguments after every firing.

-----

## Example Usage

```Lua
New "TextButton" {
	[OnEvent "Activated"] = function(...)
		print("The button was clicked! Arguments:", ...)
	end
}
```