<nav class="fusiondoc-api-breadcrumbs">
	<span>Memory</span>
	<span>Members</span>
	<span>insert</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">insert</span>
	<span class="fusiondoc-api-type">
		-> Tasks...
	</span>
</h1>

```Lua
function Fusion.insert<Tasks...>(
	scope: Scope<unknown>,
	...: Tasks...
): Tasks...
```

Inserts destruction [tasks](../../types/task) passed in to the
[scope](../../types/scope). Returns the clean up tasks to be used for variable
declarations.


!!! success "Use scoped() method syntax"
	This function is intended to be accessed as a method on a scope:
	```Lua
	local conn, ins = scope:insert(
		RunService.Heartbeat:Connect(doUpdate),
		Instance.new("Part", workspace)
	)
	```

-----

## Parameters

<h3 markdown>
	scope
	<span class="fusiondoc-api-type">
		: <a href="../../types/scope">Scope</a>&lt;unknown&gt;
	</span>
</h3>

The [scope](../../types/scope) which should be used to store
destruction tasks.

<h3 markdown>
	...
	<span class="fusiondoc-api-type">
		: Tasks...
	</span>
</h3>

The destruction [tasks](../../types/task) which should be inserted into the
scope.

-----

<h2 markdown>
	Returns
	<span class="fusiondoc-api-type">
		-> Tasks...
	</span>
</h2>

The destruction [tasks](../../types/task) that has been inserted into the scope.

-----

## Learn More

- [Scopes tutorial](../../../../tutorials/fundamentals/scopes)
