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

-----

With that, you should have the basic idea of state objects - they're kind of
like variables, but in object form. These objects will later act like 'inputs'
into Fusion's other state management tools.

??? summary "Finished code"
	```Lua linenums="1"
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Fusion = require(ReplicatedStorage.Fusion)

	local State = Fusion.State

	local message = State("Hello")
	print("The value is:", message:get())

	message:set("World")
	print("The new value is:", message:get())
	```