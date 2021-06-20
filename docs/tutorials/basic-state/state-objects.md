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

## Why State Objects?

!!! tip "This section contains optional, extra knowledge"
	This section is mainly for people who are curious about why exactly state
	objects are used in Fusion. You don't *have* to know this if you just want
	to use state objects.

In an ideal world, we would be able to refer to variables in our UI code, for
example:

```Lua
-- the number of coins the player has
local myCoins = 10

-- ideally, this would make the text match the number of coins the player has
local counter = New "TextLabel" {
	Text = myCoins
}

-- later on, if the number of coins changes, we would like the text to update!
wait(5)
myCoins = 25
```

Unfortunately, this doesn't work. When we type `#!Lua Text = myCoins`, Lua is
*copying* the value of `myCoins` into `Text`. This means, when we change the
value of `myCoins` later, our text is unaffected.

Objects in Lua don't have this limitation - Lua never copies objects in this way:

```Lua
local function modify(variable, object)
	-- variables are *copied*, so we're only modifying the copy
	variable += 1
	-- objects are *not copied*, so this modifies the actual object
	object.value += 1
end

-- make a variable and an object, both storing 1
local variable = 1
local object = {value = 1}

-- try to pass our variable and our object somewhere else
modify(variable, object)

-- notice the object is modified, but the variable is not
print(variable) --> 1
print(object.value) --> 2
```

This means we can pass state objects around, and any code using the state object
can see the correct value at all times:


=== "Lua"
	```Lua
	local myMessage = State("Hello")

	local function logValueOf(stateObject)
		-- run a loop to print the value of the state object over time
		spawn(function()
			while true do
				print(stateObject:get())
				wait(1)
			end
		end)
	end

	logValueOf(myMessage)

	wait(2.5)
	myMessage:set("World")
	```
=== "Expected output"
	```
	Hello
	Hello
	Hello
	World
	World
	(etc)
	```

This makes our original example (involving the text label) possible, because the
value isn't copied anymore:

```Lua
-- the number of coins the player has
local myCoins = State(10)

-- this makes the text match the number of coins the player has
local counter = New "TextLabel" {
	Text = myCoins
}

-- later on, if the number of coins changes, the text will update!
wait(5)
myCoins:set(25)
```

Thanks to state objects, we can pass in `myCoins`, and Fusion can see the
correct value at all times.

We'll explore this specific example in a future tutorial in more detail,
when we talk about linking UI and state.

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