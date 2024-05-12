<nav class="fusiondoc-api-breadcrumbs">
	<span>Memory</span>
	<span>Members</span>
	<span>doCleanup</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">doCleanup</span>
	<span class="fusiondoc-api-type">
		-> ()
	</span>
</h1>

```Lua
function Fusion.doCleanup(
	task: Fusion.Task
): ()
```

Attempts to destroy all arguments based on their runtime type.

!!! warning "This is a black hole!"
	Any values you pass into `doCleanup` should be treated as completely gone.
	Make sure you remove all references to those values, and ensure your code
	never uses them again.

-----

## Parameters

<h3 markdown>
	task
	<span class="fusiondoc-api-type">
		: <a href="../../../memory/types/task">Task</a>
	</span>
</h3>

A value which should be disposed of; the value's runtime type will be inspected
to determine what should happen.

- if `function`, it is called
- ...else if `{destroy: (self) -> ()}`, `:destroy()` is called 
- ...else if `{Destroy: (self) -> ()}`, `:Destroy()` is called
- ...else if `{any}`, `doCleanup` is called on all members

When Fusion is running inside of Roblox:

- if `Instance`, `:Destroy()` is called
- ...else if `RBXScriptConnection`, `:Disconnect()` is called

If none of these conditions match, the value is ignored.

-----

## Learn More

- [Scopes tutorial](../../../../tutorials/fundamentals/scopes)