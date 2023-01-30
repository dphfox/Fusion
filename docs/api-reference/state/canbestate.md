<nav class="fusiondoc-api-breadcrumbs">
	<a href="../..">Fusion</a>
	<a href="..">State</a>
</nav>

<h1 class="fusiondoc-api-header" markdown>
	<span class="fusiondoc-api-icon" markdown>:octicons-checklist-24:</span>
	<span class="fusiondoc-api-name">CanBeState</span>
	<span class="fusiondoc-api-pills">
		<span class="fusiondoc-api-pill-type">type</span>
		<span class="fusiondoc-api-pill-since">since v0.2</span>
	</span>
</h1>

A value which may either be a [state object](../stateobject) or a constant.

Provided as a convenient shorthand for indicating that constant-ness is not
important.

```Lua
StateObject<T> | T
```

-----

## Example Usage

```Lua
local function printItem(item: CanBeState<string>)
    if typeof(item) == "string" then
        -- constant
        print("Got constant: ", item)
    else
        -- state object
        print("Got state object: ", item:get())
    end
end

local constant = "Hello"
local state = Value("World")

printItem(constant) --> Got constant: Hello
printItem(state) --> Got state object: World
```