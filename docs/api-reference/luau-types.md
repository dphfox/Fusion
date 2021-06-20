Fusion exposes some public Luau types for developers working with strictly typed
codebases. These types are exported from the Fusion module directly.

!!! bug "In Development"
	Fusion's types are currently in heavy development, and are prone to massive
	changes. Accordingly, don't depend on these types for production work yet.

-----

## `State<T>`

An object storing some UI state, such as a [state object](/api-reference/state)
or a [computed object](/api-reference/computed).

The generic type `T` corresponds to the type of value stored in the object. The
value of the object can be accessed via a `:get()` method.

```Lua
local myNumber: State<number> = State(5)
local myMessage: State<string> = Computed(function()
	return "The number is: " .. myNumber:get()
end)
```

-----

## `StateOrValue<T>`

Represents either a variable of type `T`, or some UI state of type `T`.

This is equivalent to `State<T> | T`.

```Lua
local function accept(item: StateOrValue<string>)
	if typeof(item) == "string" then
		-- variable of type string
		print("variable:", item)
	else
		-- state/computed object containing a string
		print("state/computed object:", item:get())
	end
end

accept("Hello")
accept(State("World"))
accept(Computed("Goodbye"))
```

-----

## `Symbol`

Represents a named symbol. Symbols are named constants which carry special
meaning.

In Fusion, symbols are commonly used for special keys, such as
[Children](/api-reference/children) or [OnEvent](/api-reference/onevent).

```Lua
local example: Symbol = Fusion.Children
```