<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">Memory</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-checklist-24:</span>
	<span class="fusiondoc-api-name">Task</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">type</span>
		<span class="fusiondoc-api-pill-since">since v0.3</span>
	</span>
</h1>

Represents types which have default cleanup behaviour defined by Fusion.

```Lua
Instance | RBXScriptConnection | () -> () | {destroy: (self) -> ()} | {Destroy: (self) -> ()} | {Task}
```

-----

## Example Usage

```Lua
local stuff: {Task} = {
	workspace.Part1,
	RunService.RenderStepped:Connect(print),
	function()
		print("I will be run!")
	end
}

doCleanup(stuff)
```

-----

## Destruction Behaviour

Destruction behaviour varies by type:

- if `Instance`, `:Destroy()` is called
- ...else if `RBXScriptConnection`, `:Disconnect()` is called
- ...else if `function`, it is called
- ...else if `{destroy: (self) -> ()}`, `:destroy()` is called 
- ...else if `{Destroy: (self) -> ()}`, `:Destroy()` is called
- ...else if `{any}`, `Fusion.cleanup` is called on all members
- ...else nothing occurs.