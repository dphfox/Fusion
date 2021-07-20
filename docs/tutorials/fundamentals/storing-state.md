Our UIs may use some data - called 'state' - to change how it appears. Let's
learn how to store this data in Fusion.

??? abstract "Required code"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)
	```

-----

## What is State?

State is (simplistically) the variables that determine what your UI looks like
at a given point in time.

A simple example of this is a health bar. To know what the health bar looks like
at any point in time, we need to know two things:

- the current health to show
- the max health of the player

These two variables are therefore known as the 'state' of the health bar. To
show the health bar on the screen, we need to use the values of these variables.

-----

## Storing State

Fusion provides some nice tools for manipulating state and using it in our UI,
but in order to use those tools, we need to store our state in 'state objects' -
simple OOP objects that store a single value.

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

With that, you should now have a basic idea of what state objects do - by using
these, we can now easily manipulate and use it in our UIs.

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