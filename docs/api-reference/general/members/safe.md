<nav class="fusiondoc-api-breadcrumbs">
	<span>General</span>
	<span>Members</span>
	<span>Safe</span>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-workflow-24:</span>
	<span class="fusiondoc-api-name">Safe</span>
	<span class="fusiondoc-api-type">
		-> Success | Fail
	</span>
</h1>

```Lua
function Fusion.Safe<Success, Fail>(
	callbacks: {
		try: () -> Success,
		fallback: (err: unknown) -> Fail
	}
): Success | Fail
```

Safely runs a function and returns the value it produces. If the function fails,
the `fallback` function can handle the error and produces a fallback value.

`Safe` acts like a version of `xpcall` that ;s easier to use in calculations and
expressions, because it only returns the values from the functions, rather than
returning a success boolean.

-----

## Properties

<h3 markdown>
	try
	<span class="fusiondoc-api-type">
		: () -> Success
	</span>
</h3>

The possibly erroneous calculation or expression.

<h3 markdown>
	fallback
	<span class="fusiondoc-api-type">
		: (err: unknown) -> Fail
	</span>
</h3>

A fallback calculation that should provide a backup answer if the possibly
erroneous calculation throws an error.

-----

<h2 markdown>
	Returns
	<span class="fusiondoc-api-type">
		-> Success | Fail
	</span>
</h2>

The value produced by `try()` if it's successful, or the value produced by
`fallback()` if an error occurs during `try()`.