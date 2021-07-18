Some cut content on why state objects and computed objects are used in Fusion.

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

## Why Computed Objects?

!!! tip "This section contains optional, extra knowledge"
	This section is mainly for people who are curious about why exactly computed
	objects are used in Fusion. You don't *have* to know this if you just want
	to use computed objects.

Looking at a computed object, it might look similar to a function in nature. You
might be wondering why we don't just use functions for computations like this.

It's true that in simple examples, you wouldn't notice any difference between an
object-based and function-based approach:

```Lua
local numPlayers = State(5)

local function getMessage()
	return "There are " .. numPlayers:get() .. " players online."
end
```

This function seems to have all the desirable properties of a computed object -
it won't have any data desynchronisation issues, for example:

=== "Lua"
	```Lua
	local numPlayers = State(5)
	local function getMessage()
		return "There are " .. numPlayers:get() .. " players online."
	end)

	print(getMessage())

	numPlayers:set(12)
	print(getMessage())
	```
=== "Expected output"
	``` hl_lines="2"
	There are 5 players online.
	There are 12 players online.
	```

However, there's fundamentally a problem with this approach - we don't know when
this function's value changes. It could change at any time, based on any
variables, for any reason. The behaviour of the function is unpredictable.

This makes it difficult to optimise - if we wanted to set some text label's
`Text` property so it matches a function, for example, we'd have to poll the
function's value every single frame, just to check if the value changed. This is
extremely bad for performance.

One simple solution to this problem is to provide a 'changed' event alongside
the function, and fire the event whenever the function has changed it's value.
This solves the above problem nicely, and allows us to perform caching to
further improve performance.

It turns out that this is actually where computed objects originally came from -
conceptually, they're just a function with a changed event attached! The only
difference is that it's all wrapped up nicely in an object-oriented API, so you
don't have to worry about those details.

From there, the only difference to 'real' computed objects is all of the extra
features Fusion provides to make these objects easier to write and optimise, for
example automatically detecting which state objects you're using, and updating
your objects for you.