UI often depends on data being updated over time, for example round timers and
money counters. Let's learn how to store simple values that change over time.

??? abstract "Required code"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)
	```

-----

## Storing Single Values

Fusion has multiple tools for dealing with 'state' - the pieces of data that
change over time in your UI. The simplest is the State object, an OOP object
that stores a single value.

To use state objects, we first need to import the `State` constructor:

```Lua linenums="1" hl_lines="4"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Fusion)

local State = Fusion.State
```

Now, we can create a state object by calling the constructor. If you pass in a
value, it'll be stored inside the state object:

```Lua linenums="1" hl_lines="6"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Fusion)

local State = Fusion.State

local message = State("Hello")
```

At any time, you can get the currently stored value with the `:get()` method:

=== "Lua"
	```Lua linenums="1" hl_lines="7"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	local State = Fusion.State

	local message = State("Hello")
	print("The value is:", message:get())
	```
=== "Expected output"
	``` hl_lines="1"
	The value is: Hello
	```

You can also set the value by calling `:set()` with a new value:

=== "Lua"
	```Lua linenums="1" hl_lines="9-10"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	local State = Fusion.State

	local message = State("Hello")
	print("The value is:", message:get())

	message:set("World")
	print("The new value is:", message:get())
	```
=== "Expected output"
	``` hl_lines="2"
	The value is: Hello
	The new value is: World
	```

That's the basic idea of state objects - they're kind of like variables, but in
object form.

-----

## Listening for Changes

You can listen for changes using the `onChange` event, which will fire every
time a new value is stored in the state object:

=== "Lua"
	```Lua linenums="1" hl_lines="9-11"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	local State = Fusion.State

	local message = State("Hello")
	print("The value is:", message:get())

	local disconnect = message.onChange:Connect(function()
		print("The message was changed!")
	end)

	message:set("World")
	print("The new value is:", message:get())
	```
=== "Expected output"
	``` hl_lines="2"
	The value is: Hello
	The message was changed!
	The new value is: World
	```

If you'd like to disconnect from the event later, `:Connect()` returns a
function which, when called, will disconnect your event handler:

=== "Lua"
	```Lua linenums="1" hl_lines="16-19"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	local State = Fusion.State

	local message = State("Hello")
	print("The value is:", message:get())

	local disconnect = message.onChange:Connect(function()
		print("The message was changed!")
	end)

	message:set("World")
	print("The new value is:", message:get())

	disconnect()

	message:set("Sneaky")
	print("The final value is:", message:get())
	```
=== "Expected output"
	``` hl_lines="4"
	The value is: Hello
	The message was changed!
	The new value is: World
	The final value is: Sneaky
	```

-----

With that, you should now have a basic idea of what state objects can do -
they're the simplest and most fundamental tool Fusion offers for managing state.

??? summary "Finished code"
	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	local State = Fusion.State

	local message = State("Hello")
	print("The value is:", message:get())

	local disconnect = message.onChange:Connect(function()
		print("The message was changed!")
	end)

	message:set("World")
	print("The new value is:", message:get())

	disconnect()

	message:set("Sneaky")
	print("The final value is:", message:get())
	```