Usually, we don't use state as-is in our UI; we normally process it first. Let's
learn how to perform computations on our state.

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
objects'*. Instead of storing a fixed value, they run a computation. Think of it
like a spreadsheet, where you can type in an equation that uses other values.

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

Now for the magic - whenever you use a state object as part of your computation,
the computed object will update when the state object changes:

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

This solves our previous 'data desynchronisation' issue - we don't have to
manually recalculate the message. Instead, Fusion handles it for us, because
we're storing our state in Fusion's objects.

That's the basic idea of computed objects; they let you naturally define values
in terms of other values.

!!! danger "Danger - Yielding"
	Code inside of a computed callback should never yield. While Fusion does not
	currently throw an error for this, there are plans to change this.

	Yielding in a callback may break a lot of Fusion code which depends on
	updates to your variables being instant, for example dependency management.
	It can also lead to internally inconsistent code.

	If you need to perform a web call when some state changes, consider using
	`Compat(state):onChange()` to bind a change listener, which *is* allowed to
	yield, and store the result of the web call in a state object for use
	elsewhere:

	```Lua
	local playerID = State(1670764)

	-- bad - this will break!
	local playerData = Computed(function()
		return ReplicatedStorage.GetPlayerData:InvokeServer(playerID:get())
	end)

	-- better - this moves the yielding safely outside of any state objects
	-- make sure to load the data for the first time if that's important
	local playerData = State(nil)
	Compat(playerData):onChange(function()
		playerData:set(ReplicatedStorage.GetPlayerData:InvokeServer(playerID:get()))
	end)
	```

	In the future, there are plans to make yielding code easier to work with.
	[See this issue for more details.](https://github.com/Elttob/Fusion/issues/4)

!!! danger "Danger - Using non-state objects"
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

	numPlayers:set(12)
	print(message:get())
	```