<nav class="fusiondoc-api-breadcrumbs">
	<span>General</span>
	<span>Types</span>
	<span>Version</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-note-24:</span>
	<span class="fusiondoc-api-name">Version</span>
</h1>

```Lua
export type Version = {
	major: number,
	minor: number,
	isRelease: boolean
}
```

Describes a version of Fusion's source code.

-----

## Members

<h2 markdown>
	major
	<span class="fusiondoc-api-type">
		: number
	</span>
</h2>

The major version number. If this is greater than `0`, then two versions sharing
the same major version number are not expected to be incompatible or have
breaking changes.

<h2 markdown>
	minor
	<span class="fusiondoc-api-type">
		: number
	</span>
</h2>

The minor version number. Describes version updates that are not enumerated by
the major version number, such as versions prior to 1.0, or versions which
are non-breaking.

<h2 markdown>
	isRelease
	<span class="fusiondoc-api-type">
		: boolean
	</span>
</h2>

Describes whether the version was sourced from an official release package.