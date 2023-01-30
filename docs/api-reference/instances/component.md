<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">Instances</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-checklist-24:</span>
	<span class="fusiondoc-api-name">Component</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">type</span>
		<span class="fusiondoc-api-pill-since">since v0.2</span>
	</span>
</h1>

The standard type signature for UI components. They accept a property table and
return a [child type](./child.md).

```Lua
(props: {[any]: any}) -> Child
```

-----

## Example Usage

```Lua
-- create a Button component
local function Button(props)
    return New "TextButton" {
        Text = props.Text
    }
end

-- the Button component is compatible with the Component type
local myComponent: Component = Button
```