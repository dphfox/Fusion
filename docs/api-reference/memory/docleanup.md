<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">Memory</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-code-24:</span>
	<span class="fusiondoc-api-name">doCleanup</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">function</span>
		<span class="fusiondoc-api-pill-since">since v0.3</span>
	</span>
</h1>

Attempts to clean up all [tasks](../task) passed to it. Values which are not tasks
are ignored.

```Lua
(...any) -> ()
```

-----

## Parameters

- `...` - Any objects that need to be destroyed.

-----

## Example Usage

```Lua
doCleanup(
	workspace.Part1,
	RunService.RenderStepped:Connect(print),
	function()
		print("I will be run!")
	end
)
```