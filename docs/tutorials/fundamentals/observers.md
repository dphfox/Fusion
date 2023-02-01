Observers allow you to detect when any state object changes value. You can
connect handlers using `:onChange()`, which returns a function you can call to
disconnect it later.

```Lua
local observer = Observer(health)

local disconnect = observer:onChange(function()
	print("The new value is: ", health:get())
end)

task.wait(5)
disconnect()
```

-----

## Usage

To use `Observer` in your code, you first need to import it from the Fusion
module, so that you can refer to it by name:

```Lua linenums="1" hl_lines="2"
local Fusion = require(ReplicatedStorage.Fusion)
local Observer = Fusion.Observer
```

To create a new observer, call the `Observer` function with an object to watch:

```Lua
local health = Value(100)

-- This observer will watch `health` for changes:
local observer = Observer(health)
```

When the watched object changes value, the observer will run all of its handlers.
To add a handler, you can use `:onChange()`:

```Lua
local disconnect = observer:onChange(function()
	print("The new value is: ", health:get())
end)
```

When you're done with the handler, it's very important to disconnect it. The
`:onChange()` method returns a function you can call to disconnect your handler:

```Lua
local disconnect = observer:onChange(function()
	print("The new value is: ", health:get())
end)

-- disconnect the above handler after 5 seconds
task.wait(5)
disconnect()
```

??? question "Why is disconnecting so important?"
	While an observer has at least one active handler, it will hold the watched
	object in memory forcibly. This is done to make sure that changes aren't
	missed.

	Disconnecting your handlers tells Fusion you don't need to track changes
	any more, which allows it to clean up the observer and the watched object.

-----

## What Counts As A Change?

You might notice that not all calls to `Value:set()` will cause your observer to
run:

=== "Script code"

	```Lua
	local thing = Value("Hello")

	Observer(thing):onChange(function()
		print("=> Thing changed to", thing:get())
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

When you set the value, if it's the same as the existing value, an update won't
be sent out. This means observers won't re-run when you set the
value multiple times in a row.

![A diagram showing how value objects only send updates if the new value and previous value aren't equal.](Value-Equality-Dark.svg#only-dark)
![A diagram showing how value objects only send updates if the new value and previous value aren't equal.](Value-Equality-Light.svg#only-light)

In most cases, this leads to improved performance because your code runs less
often. However, if you need to override this behaviour, `Value:set()` accepts a
second argument - if you set it to `true`, an update will be forced:

=== "Script code"

	```Lua hl_lines="11-12"
	local thing = Value("Hello")

	Observer(thing):onChange(function()
		print("=> Thing changed to", thing:get())
	end)

	print("Setting thing once...")
	thing:set("World")
	print("Setting thing twice...")
	thing:set("World")
	print("Setting thing thrice (update forced)...")
	thing:set("World", true)
	```

=== "Output"

	``` hl_lines="4-5"
	Setting thing once...
	=> Thing changed to World
	Setting thing twice...
	Setting thing thrice (update forced)...
	=> Thing changed to World
	```