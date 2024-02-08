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

```Lua linenums="6" hl_lines="3"
local scope = scoped(Fusion)
local health = scope:Value(5)
local observer = scope:Observer(health)
```

The observer will watch the state object for changes until it's destroyed. You
can take advantage of this by connecting your own code using the observer's
different methods.

The first method is `:onChange()`, which runs your code when the state object
changes value.

=== "Luau code"

	```Lua linenums="8" hl_lines="4-6"
	local observer = scope:Observer(health)

	print("...connecting...")
	observer:onChange(function()
		print("Observed a change to: ", peek(health))
	end)

	print("...setting health to 25...")
	health:set(25)
	```

=== "Output"

	```
	...connecting...
	...setting health to 25...
	Observed a change to: 25
	```

By default, the `:onChange()` connection is disconnected when the observer
object is destroyed. However, if you want to disconnect it earlier, the
`:onChange()` method returns an optional disconnect function. Calling it will
disconnect that specific `:onChange()` handler early.

```Lua linenums="8" hl_lines="1 7"
local disconnect = observer:onChange(function()
	print("The new value is: ", peek(health))
end)

-- disconnect the above handler after 5 seconds
task.wait(5)
disconnect()
```

The second method is `:onBind()`. It works identically to `:onChange()`, but it
also runs your code right away, which can often be useful.

=== "Luau code"

	```Lua linenums="8" hl_lines="4"
	local observer = scope:Observer(health)

	print("...connecting...")
	observer:onBind(function()
		print("Observed a change to: ", peek(health))
	end)

	print("...setting health to 25...")
	health:set(25)
	```

=== "Output"

	```
	...connecting...
	Observed a change to: 5
	...setting health to 25...
	Observed a change to: 25
	```

-----

## What Counts As A Change?

If you set the `health` to the same value multiple times in a row, you might
notice your observer only runs the first time.

=== "Luau code"

	```Lua linenums="8"
	local observer = scope:Observer(health)

	observer:onChange(function()
		print("Observed a change to: ", peek(health))
	end)

	print("...setting health to 25 three times...")
	health:set(25)
	health:set(25)
	health:set(25)
	```

=== "Output"

	```
	...setting health to 25 three times...
	Observed a change to: 25
	```

This is because the `health` object sees that it isn't actually changing value,
so it doesn't broadcast any updates. Therefore, our observer doesn't run.

This leads to improved performance because your code runs less often. Fusion
applies these kinds of optimisations generously throughout your program.