<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">Instances</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-checklist-24:</span>
	<span class="fusiondoc-api-name">Child</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">type</span>
		<span class="fusiondoc-api-pill-since">since v0.2</span>
	</span>
</h1>

Represents some UI which can be parented to an ancestor, usually via [Children](./children.md).
The most simple kind of child is a single instance, though arrays can be used
to parent multiple instances at once and state objects can be used to make the
children dynamic.

```Lua
Instance | {[any]: Child} | StateObject<Child>
```

-----

## Example Usage

```Lua
-- all of the following fit the definition of Child

local child1: Child = New "Folder" {}
local child2: Child = {
    New "Folder" {},
    New "Folder" {},
    New "Folder" {}
}
local child3: Child = Computed(function()
    return New "Folder" {}
end)
local child4: Child = {
    Computed(function()
        return New "Folder" {}
    end),
    {New "Folder" {}, New "Folder" {}}
}
```