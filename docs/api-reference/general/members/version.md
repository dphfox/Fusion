<nav class="fusiondoc-api-breadcrumbs">
	<span>General</span>
	<span>Members</span>
	<span>version</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">version</span>
	<a href="../../types/version" class="fusiondoc-api-type">
		: Version
	</a>
</h1>

```Lua
Fusion.version = {
	major = 0,
	minor = 3,
	isRelease = false
}
```

The version of the Fusion source code.

`isRelease` is only `true` when using a version of Fusion downloaded from
[the Releases page](https://github.com/dphfox/Fusion/releases).