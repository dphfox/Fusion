Often, we don't use raw values directly in our UI; instead, we need to perform
computations on those values. Let's learn how to compute new values from existing
ones.

??? abstract "Required code"

	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	local State = Fusion.State

	local numPlayers = State(5)
	```

-----

## The Computation Problem

In UI development, lots of values are computed based on other values. For
example, you might compute a message based on the number of players online:

```Lua
local numPlayers = 5
local message = "There are " .. numPlayers .. " players online."
```

However, there's a problem - when `numPlayers` changes, we have to manually
re-calculate the `message` value ourselves. If you don't, then the message will
show the wrong amount of players - an issue known as 'data desynchronisation'.

-----

## Computed Objects

To solve this problem, Fusion introduces a second kind of object - *'computed
objects'*. Instead of storing a fixed value, they run a computation based on
other state objects.

To use computed objects, we first need to import the `Computed` constructor:

```Lua linenums="1" hl_lines="5"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Fusion)

local State = Fusion.State
local Computed = Fusion.Computed
```

Now, we can create a computed object by calling the constructor. We pass in our
computation as a function:

```Lua linenums="7" hl_lines="2-4"
local numPlayers = State(5)
local message = Computed(function()
	return "There are " .. numPlayers:get() .. " players online."
end)
```

At any time, you can get the computed value with the `:get()` method:

=== "Lua"
	```Lua linenums="7" hl_lines="6"
	local numPlayers = State(5)
	local message = Computed(function()
		return "There are " .. numPlayers:get() .. " players online."
	end)

	print(message:get())
	```
=== "Expected output"
	``` hl_lines="1"
	There are 5 players online.
	```

When you use another state object in your computation, the computed object will
update whenever the state object changes value:

=== "Lua"
	```Lua linenums="7" hl_lines="8-9"
	local numPlayers = State(5)
	local message = Computed(function()
		return "There are " .. numPlayers:get() .. " players online."
	end)

	print(message:get())

	numPlayers:set(12)
	print(message:get())
	```
=== "Expected output"
	``` hl_lines="2"
	There are 5 players online.
	There are 12 players online.
	```

That's the basic idea of computed objects; they let you define your values
*reactively*, i.e. as automatically-updating computations.

!!! danger
	Stick to using state objects and computed objects inside your computations.
	Fusion can detect when you use these objects and listen for changes.

	Fusion *can't* automatically detect changes when you use 'normal' variables:

	```Lua
	local theVariable = "Hello"
	local badValue = Computed(function()
		-- don't do this! use state objects or computed objects in here
		return "Say " .. theVariable
	end)

	print(badValue:get()) -- prints 'Say Hello'

	theVariable = "World"
	print(badValue:get()) -- still prints 'Say Hello' - that's a problem!
	```

	By using a state object here, Fusion can correctly update the computed
	object, because it knows we used the state object:

	```Lua
	local theVariable = State("Hello")
	local goodValue = Computed(function()
		-- this is much better - Fusion can detect we used this state object!
		return "Say " .. theVariable:get()
	end)

	print(goodValue:get()) -- prints 'Say Hello'

	theVariable:set("World")
	print(goodValue:get()) -- prints 'Say World'
	```

	This also applies to any functions that change on their own, like
	`os.clock()`. If you need to use them, store values from the function in a
	state object, and update the value of that object as often as required.

-----

## Listening for Changes

You can listen for changes using the `onChange` event, which will fire every
time the computed object updates its value:

=== "Lua"
	```Lua linenums="7" hl_lines="8-10"
	local numPlayers = State(5)
	local message = Computed(function()
		return "There are " .. numPlayers:get() .. " players online."
	end)

	print(message:get())

	local disconnect = message.onChange:Connect(function()
		print("The message was changed!")
	end)

	numPlayers:set(12)
	print(message:get())
	```
=== "Expected output"
	``` hl_lines="2"
	There are 5 players online.
	The message was changed!
	There are 12 players online.
	```

If you'd like to disconnect from the event later, `:Connect()` returns a
function which, when called, will disconnect your event handler:

=== "Lua"
	```Lua linenums="7" hl_lines="15-18"
	local numPlayers = State(5)
	local message = Computed(function()
		return "There are " .. numPlayers:get() .. " players online."
	end)

	print(message:get())

	local disconnect = message.onChange:Connect(function()
		print("The message was changed!")
	end)

	numPlayers:set(12)
	print(message:get())

	disconnect()

	numPlayers:set(0)
	print(message:get())
	```
=== "Expected output"
	``` hl_lines="4"
	There are 5 players online.
	The message was changed!
	There are 12 players online.
	There are 0 players online.
	```

-----

Now, we've covered everything we need to know about Fusion's basic state tools.
Using computed objects and state objects together, you can easily store and
compute values while avoiding data desynchronisation bugs.

??? summary "Finished code"
	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	local State = Fusion.State
	local Computed = Fusion.Computed

	local numPlayers = State(5)
	local message = Computed(function()
		return "There are " .. numPlayers:get() .. " players online."
	end)

	print(message:get())

	local disconnect = message.onChange:Connect(function()
		print("The message was changed!")
	end)

	numPlayers:set(12)
	print(message:get())

	disconnect()

	numPlayers:set(0)
	print(message:get())
	```