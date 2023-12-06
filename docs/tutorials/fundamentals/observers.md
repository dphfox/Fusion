When you're working with state objects, it can be useful to detect various
changes that happen to them.

Observers allow you to detect those changes. Create one with a state object to
'watch', then connect code to run using `:onChange()` or `:onBind()`.

```Lua
local observer = scope:Observer(health)
local disconnect = observer:onChange(function()
	print("The new value is: ", peek(health))
end)
task.wait(5)
disconnect()
```

-----

## Usage

To create a new observer object, call `scope:Observer()` and give it a state
object you want to detect changes on.

```Lua linenums="5" hl_lines="3"
local scope = scoped(Fusion)
local health = scope:Value(5)
local observer = scope:Observer(health)
```

The observer will watch the state object for changes until it's destroyed. You
can take advantage of this by connecting your own code using the observer's
different methods.

The first method is `:onChange()`, which runs your code when the state object
changes value.

```Lua
observer:onChange(function()
	print("The new value is: ", peek(health))
end)
```

By default, the `:onChange()` connection is disconnected when the observer
object is destroyed. However, if you want to disconnect it earlier, the
`:onChange()` method returns an optional disconnect function. Calling it will
disconnect that specific `:onChange()` handler early.

```Lua
local disconnect = observer:onChange(function()
	print("The new value is: ", peek(health))
end)

-- disconnect the above handler after 5 seconds
task.wait(5)
disconnect()
```

The second method is `:onBind()`. It works identically to `:onChange()`, but it
also runs your code right away, which can often be useful.

```Lua
local disconnect = observer:onBind(function()
	print("The new value is: ", peek(health))
end)

-- disconnect the above handler after 5 seconds
task.wait(5)
disconnect()
```

-----

## What Counts As A Change?

If you set the `health` to the same value multiple times in a row, you might
notice your observer only runs the first time.

=== "Luau code"

	```Lua
	local thing = Value("Hello")

	Observer(thing):onChange(function()
		print("=> Thing changed to", peek(thing))
	end)

	print("Setting thing once...")
	thing:set("World")
	print("Setting thing twice...")
	thing:set("World")
	print("Setting thing thrice...")
	thing:set("World")
	```

=== "Output"

	```
	Setting thing once...
	=> Thing changed to World
	Setting thing twice...
	Setting thing thrice...
	```

This is because the `health` object sees that it isn't actually changing value,
so it doesn't broadcast any updates. Therefore, our observer doesn't run.

![A diagram showing how value objects only send updates if the new value and previous value aren't equal.](Value-Equality-Dark.svg#only-dark)
![A diagram showing how value objects only send updates if the new value and previous value aren't equal.](Value-Equality-Light.svg#only-light)

This leads to improved performance because your code runs less often. Fusion
applies these kinds of optimisations generously throughout your program.