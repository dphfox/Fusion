<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">Instances</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-code-24:</span>
	<span class="fusiondoc-api-name">OnChange</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">function</span>
		<span class="fusiondoc-api-pill-since">since v0.1</span>
	</span>
</h1>

Given a property name, returns a [special key](./specialkey.md) which connects
to that property's change events. It should be used with a handler callback,
which may accept the new value of the property.

```Lua
(propertyName: string) -> SpecialKey
```

-----

## Parameters

- `propertyName` - The name of the property to listen for changes to.

-----

## Returns

A special key which runs at the `observer` stage. When applied to an instance,
it connects to the property change signal on the instance for the given property.
The handler is run with the property's value after every change.

-----

## Example Usage

```Lua
New "TextBox" {
    [OnChange "Text"] = function(newText)
        print("You typed:", newText)
    end
}
```